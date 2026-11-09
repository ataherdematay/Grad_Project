package com.bitadilat.pro.dto;

import com.bitadilat.pro.Availability;
import com.bitadilat.pro.ReviewStatus;
import java.math.BigDecimal;
import java.util.List;

public record ProfileView(String businessName, String bio, int experienceYears, List<String> categoryIds,
                          List<Integer> districtIds, List<WorkingHourDto> workingHours, ReviewStatus reviewStatus,
                          Availability availability, BigDecimal ratingAvg, int ratingCount, int completedJobs) {
}
