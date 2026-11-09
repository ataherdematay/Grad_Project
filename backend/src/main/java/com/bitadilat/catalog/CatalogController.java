package com.bitadilat.catalog;

import com.bitadilat.common.ApiException;
import java.text.Collator;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class CatalogController {

    public record CategoryView(String id, String nameTr, String nameEn, String icon, String colorHex, int sortOrder) {
    }

    public record DistrictView(Integer id, String name, District.Side side) {
    }

    private final CategoryRepository categories;
    private final DistrictRepository districts;

    private final com.bitadilat.request.QuestionCatalog questions;

    public CatalogController(CategoryRepository categories, DistrictRepository districts,
                             com.bitadilat.request.QuestionCatalog questions) {
        this.categories = categories;
        this.districts = districts;
        this.questions = questions;
    }

    @GetMapping("/categories")
    public List<CategoryView> categories() {
        return categories.findByActiveTrueOrderBySortOrderAsc().stream()
                .map(c -> new CategoryView(c.getId(), c.getNameTr(), c.getNameEn(), c.getIcon(), c.getColorHex(),
                        c.getSortOrder()))
                .toList();
    }

    @GetMapping("/districts")
    public List<DistrictView> districts() {
        // Sıralama Türk alfabesine göre Java'da yapılır; veritabanı harmanlaması (C, en_US, macOS) Ç/Ş/Ü'yü yanlış dizer.
        Collator turkish = Collator.getInstance(Locale.forLanguageTag("tr-TR"));
        return districts.findByActiveTrueOrderByNameAsc().stream()
                .sorted(Comparator.comparing(District::getName, turkish))
                .map(d -> new DistrictView(d.getId(), d.getName(), d.getSide()))
                .toList();
    }

    /** Kategoriye özel sihirbaz soruları (tek seçim). */
    @GetMapping("/categories/{id}/questions")
    public List<com.bitadilat.request.QuestionCatalog.Question> questions(@PathVariable String id) {
        if (!categories.existsById(id)) {
            throw ApiException.notFound("Kategori bulunamadı.");
        }
        return questions.forCategory(id);
    }
}
