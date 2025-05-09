package com.example.course;

import com.example.shared.AggregateRoot;
import java.util.HashMap;
import java.util.Map;

public final class Course extends AggregateRoot {
    private final int id;
    private String name;
    private final float duration;
    private final Map<String, Object> att = new HashMap<>();

    public Course(int id, String name, float duration) {
        this.id = id;
        this.name = name;
        this.duration = duration;
    }

    public void foo() {
    }

    private String bar() {
        return "bar";
    }

    public int fizz() {
        return 0;
    }
}
