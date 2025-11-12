package com.example.orgapp.web;
import com.example.orgapp.model.Department;
import com.example.orgapp.repo.DepartmentRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
@RestController
@RequestMapping("/departments")
public class DepartmentController {
    private final DepartmentRepository repo;
    public DepartmentController(DepartmentRepository repo){ this.repo = repo; }
    @GetMapping public List<Department> all(){ return repo.findAll(); }
    @PostMapping public ResponseEntity<Department> create(@RequestBody Department d){ return ResponseEntity.ok(repo.save(d)); }
    @GetMapping("{id}") public ResponseEntity<Department> get(@PathVariable Long id){ return repo.findById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build()); }
}
