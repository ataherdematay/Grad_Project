package com.bitadilat.job.dto;

import java.util.List;

/** {@code nextCursor} yalnızca {@code limit} verildiğinde dolu olabilir; verilmezse tüm liste döner. */
public record JobList(List<JobSummary> items, String nextCursor) {
}
