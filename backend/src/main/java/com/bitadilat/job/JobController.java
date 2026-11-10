package com.bitadilat.job;

import com.bitadilat.common.security.AuthPrincipal;
import com.bitadilat.job.dto.ComplaintView;
import com.bitadilat.job.dto.JobBodies;
import com.bitadilat.job.dto.JobDetail;
import com.bitadilat.job.dto.JobList;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** İşler (docs/spec/API_V1.md "Ayrıntılı sözleşme (wave 3)"). Tüm uç noktalar kimlik ister; katılımcı olmayan 404. */
@RestController
@RequestMapping("/api/v1")
public class JobController {

    private final JobQueryService queries;
    private final JobCommandService commands;
    private final JobFeedbackService feedback;

    public JobController(JobQueryService queries, JobCommandService commands, JobFeedbackService feedback) {
        this.queries = queries;
        this.commands = commands;
        this.feedback = feedback;
    }

    @GetMapping("/jobs")
    public JobList list(@AuthenticationPrincipal AuthPrincipal p,
                        @RequestParam(value = "as", required = false) String as,
                        @RequestParam(value = "scope", defaultValue = "active") String scope,
                        @RequestParam(value = "cursor", required = false) String cursor,
                        @RequestParam(value = "limit", required = false) Integer limit) {
        return queries.list(p.userId(), as, scope, cursor, limit);
    }

    @GetMapping("/jobs/{id}")
    public JobDetail get(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id) {
        return queries.get(p.userId(), id);
    }

    @PostMapping("/jobs/{id}/appointment/proposals")
    public JobDetail propose(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id,
                             @Valid @RequestBody JobBodies.ProposeSlot body) {
        return commands.propose(p.userId(), id, body);
    }

    @PostMapping("/jobs/{id}/appointment/proposals/{pid}/accept")
    public JobDetail accept(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id, @PathVariable UUID pid) {
        return commands.acceptProposal(p.userId(), id, pid);
    }

    @PostMapping("/jobs/{id}/arrived")
    public JobDetail arrived(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id) {
        return commands.arrived(p.userId(), id);
    }

    @PostMapping("/jobs/{id}/start")
    public JobDetail start(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id) {
        return commands.start(p.userId(), id);
    }

    @PostMapping("/jobs/{id}/finish")
    public JobDetail finish(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id,
                            @Valid @RequestBody JobBodies.Finish body) {
        return commands.finish(p.userId(), id, body);
    }

    @PostMapping("/jobs/{id}/events")
    public JobDetail event(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id,
                           @Valid @RequestBody JobBodies.AddEvent body) {
        return commands.addEvent(p.userId(), id, body);
    }

    @PostMapping("/jobs/{id}/confirm")
    public JobDetail confirm(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id) {
        return commands.confirm(p.userId(), id);
    }

    @PostMapping("/jobs/{id}/cancel")
    public JobDetail cancel(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id,
                            @Valid @RequestBody JobBodies.Cancel body) {
        return commands.cancel(p.userId(), id, body);
    }

    @PostMapping("/jobs/{id}/review")
    public JobDetail review(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id,
                            @Valid @RequestBody JobBodies.Review body) {
        return feedback.review(p.userId(), id, body);
    }

    @PostMapping("/jobs/{id}/complaint")
    @ResponseStatus(HttpStatus.CREATED)
    public ComplaintView complain(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id,
                                  @Valid @RequestBody JobBodies.Complaint body) {
        return feedback.complain(p.userId(), id, body);
    }

    @GetMapping("/complaints/{id}")
    public ComplaintView complaint(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id) {
        return feedback.get(p.userId(), p.admin(), id);
    }
}
