package com.example.orgapp.model;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;

@Entity
public class Department {
  @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;
  @NotBlank private String name;

  public Department() {}
  public Department(String name) { this.name = name; }

  public Long getId() { return id; }
  public String getName() { return name; }
  public void setId(Long id) { this.id = id; }
  public void setName(String name) { this.name = name; }
}
