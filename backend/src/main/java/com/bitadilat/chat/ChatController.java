package com.bitadilat.chat;

import com.bitadilat.chat.dto.ChatDtos.ConversationList;
import com.bitadilat.chat.dto.ChatDtos.MarkRead;
import com.bitadilat.chat.dto.ChatDtos.Message;
import com.bitadilat.chat.dto.ChatDtos.MessageList;
import com.bitadilat.chat.dto.ChatDtos.SendMessage;
import com.bitadilat.common.security.AuthPrincipal;
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

@RestController
@RequestMapping("/api/v1")
public class ChatController {

    private final ChatService chat;

    public ChatController(ChatService chat) {
        this.chat = chat;
    }

    @GetMapping("/jobs/{id}/messages")
    public MessageList messages(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id,
                                @RequestParam(value = "after", required = false) Long after,
                                @RequestParam(value = "limit", required = false) Integer limit) {
        return chat.messages(p.userId(), id, after, limit);
    }

    @PostMapping("/jobs/{id}/messages")
    @ResponseStatus(HttpStatus.CREATED)
    public Message send(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id,
                        @Valid @RequestBody SendMessage body) {
        return chat.send(p.userId(), id, body);
    }

    @PostMapping("/jobs/{id}/messages/read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void read(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id,
                     @Valid @RequestBody MarkRead body) {
        chat.markRead(p.userId(), id, body.lastReadId());
    }

    @GetMapping("/conversations")
    public ConversationList conversations(@AuthenticationPrincipal AuthPrincipal p,
                                          @RequestParam(value = "as", required = false) String as) {
        return chat.conversations(p.userId(), as);
    }
}
