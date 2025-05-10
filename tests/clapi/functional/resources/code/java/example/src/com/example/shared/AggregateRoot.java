package com.example.shared;

import java.util.ArrayList;
import java.util.List;

public class AggregateRoot {
    private List<Object> domainEvents = new ArrayList<>();

    protected final void record(Object domainEvent) {
        this.domainEvents.add(domainEvent);
    }

    public final List<Object> pullDomainEvents() {
        List<Object> events = new ArrayList<>(this.domainEvents);
        this.domainEvents.clear();
        return events;
    }
}
