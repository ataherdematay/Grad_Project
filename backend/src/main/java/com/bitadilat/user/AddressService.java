package com.bitadilat.user;

import com.bitadilat.catalog.District;
import com.bitadilat.catalog.DistrictRepository;
import com.bitadilat.common.AesGcmCrypto;
import com.bitadilat.common.ApiException;
import com.bitadilat.user.dto.AddressPatch;
import com.bitadilat.user.dto.AddressRequest;
import com.bitadilat.user.dto.AddressView;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Adres CRUD. Tam adres ve kapı notu AES-GCM ile şifrelenir (AAD = kullanıcı kimliği). Başkasının adresi
 * "yok" sayılır (404), varlığı sızmaz.
 */
@Service
public class AddressService {

    private final AddressRepository addresses;
    private final DistrictRepository districts;
    private final AesGcmCrypto crypto;

    public AddressService(AddressRepository addresses, DistrictRepository districts, AesGcmCrypto crypto) {
        this.addresses = addresses;
        this.districts = districts;
        this.crypto = crypto;
    }

    @Transactional(readOnly = true)
    public List<AddressView> list(UUID userId) {
        List<Address> all = addresses.findByUserIdOrderByDefaultAddressDescCreatedAtAsc(userId);
        Map<Integer, String> names = districtNames();
        return all.stream().map(a -> view(a, names)).toList();
    }

    @Transactional(readOnly = true)
    public AddressView get(UUID userId, UUID id) {
        return view(find(userId, id), districtNames());
    }

    @Transactional
    public AddressView create(UUID userId, AddressRequest request) {
        requireDistrict(request.districtId());
        boolean makeDefault = Boolean.TRUE.equals(request.isDefault()) || addresses.countByUserId(userId) == 0;
        if (makeDefault) {
            addresses.clearDefaults(userId);
        }
        Address a = new Address();
        a.setUserId(userId);
        a.setLabel(request.label().trim());
        a.setDistrictId(request.districtId());
        a.setNeighborhood(request.neighborhood().trim());
        a.setLineFullEncrypted(crypto.encrypt(request.lineFull().trim(), aad(userId)));
        a.setDoorNoteEncrypted(encryptNote(request.doorNote(), userId));
        a.setDefaultAddress(makeDefault);
        return view(addresses.save(a), districtNames());
    }

    @Transactional
    public AddressView update(UUID userId, UUID id, AddressPatch patch) {
        find(userId, id); // 404 kontrolü
        if (patch.districtId() != null) {
            requireDistrict(patch.districtId());
        }
        boolean promote = Boolean.TRUE.equals(patch.isDefault());
        if (promote) {
            addresses.clearDefaults(userId); // yönetilen varlıkları ayırır, bu yüzden yeniden yüklenir
        }
        Address a = find(userId, id);
        if (patch.label() != null) {
            a.setLabel(patch.label().trim());
        }
        if (patch.districtId() != null) {
            a.setDistrictId(patch.districtId());
        }
        if (patch.neighborhood() != null) {
            a.setNeighborhood(patch.neighborhood().trim());
        }
        if (patch.lineFull() != null) {
            a.setLineFullEncrypted(crypto.encrypt(patch.lineFull().trim(), aad(userId)));
        }
        if (patch.doorNote() != null) {
            a.setDoorNoteEncrypted(encryptNote(patch.doorNote(), userId));
        }
        if (promote) {
            a.setDefaultAddress(true);
        }
        return view(addresses.save(a), districtNames());
    }

    @Transactional
    public void delete(UUID userId, UUID id) {
        Address a = find(userId, id);
        boolean wasDefault = a.isDefaultAddress();
        addresses.delete(a);
        addresses.flush();
        if (wasDefault) {
            addresses.findByUserIdOrderByDefaultAddressDescCreatedAtAsc(userId).stream().findFirst()
                    .ifPresent(next -> {
                        next.setDefaultAddress(true);
                        addresses.save(next);
                    });
        }
    }

    private Address find(UUID userId, UUID id) {
        return addresses.findByIdAndUserId(id, userId)
                .orElseThrow(() -> ApiException.notFound("Adres bulunamadı."));
    }

    private void requireDistrict(Integer districtId) {
        if (!districts.findById(districtId).map(District::isActive).orElse(false)) {
            throw ApiException.validation("districtId", "İlçe bulunamadı.");
        }
    }

    private String encryptNote(String note, UUID userId) {
        return note == null || note.isBlank() ? null : crypto.encrypt(note.trim(), aad(userId));
    }

    private AddressView view(Address a, Map<Integer, String> names) {
        return new AddressView(a.getId(), a.getLabel(), a.getDistrictId(), names.get(a.getDistrictId()),
                a.getNeighborhood(), crypto.decrypt(a.getLineFullEncrypted(), aad(a.getUserId())),
                crypto.decrypt(a.getDoorNoteEncrypted(), aad(a.getUserId())), a.isDefaultAddress());
    }

    private Map<Integer, String> districtNames() {
        return districts.findAll().stream().collect(Collectors.toMap(District::getId, District::getName,
                (x, y) -> x));
    }

    private static String aad(UUID userId) {
        return "addr:" + userId;
    }
}
