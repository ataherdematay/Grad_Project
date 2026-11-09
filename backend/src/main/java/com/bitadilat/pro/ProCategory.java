package com.bitadilat.pro;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import java.io.Serializable;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "pro_categories")
@IdClass(ProCategory.Key.class)
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class ProCategory {

    @Id
    private UUID proId;

    @Id
    private String categoryId;

    @EqualsAndHashCode
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Key implements Serializable {
        private UUID proId;
        private String categoryId;
    }
}
