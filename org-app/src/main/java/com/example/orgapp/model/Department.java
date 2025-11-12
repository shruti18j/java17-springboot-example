package com.example.orgapp.model;
import jakarta.persistence.*;
@Entity
public class Department {
    @Id @GeneratedValue(strategy=GenerationType.AUTO)
    private Long id;
    private String name;
    public Department() {}
    public Department(String name){ this.name = name; }
    public Long getId(){ return id; }
    public String getName(){ return name; }
    public void setName(String n){ this.name = n; }
}
