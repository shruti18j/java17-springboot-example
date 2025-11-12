package com.example.fileupload.web;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.stream.Collectors;
@RestController
public class FileController {
  private static final String BASE_DIR = "/tmp/uploads";
  @PostMapping(value="/upload", consumes=MediaType.MULTIPART_FORM_DATA_VALUE)
  public ResponseEntity<String> upload(@RequestPart("file") MultipartFile file) throws IOException {
    File dir = new File(BASE_DIR); if (!dir.exists()) dir.mkdirs();
    Path dest = Paths.get(BASE_DIR, file.getOriginalFilename());
    try (FileOutputStream out = new FileOutputStream(dest.toFile())) { out.write(file.getBytes()); }
    return ResponseEntity.ok("Uploaded: " + dest.getFileName());
  }
  @GetMapping("/download/{name}")
  public ResponseEntity<Resource> download(@PathVariable String name) throws IOException {
    Path path = Paths.get(BASE_DIR, name);
    if (!Files.exists(path)) return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    Resource res = new FileSystemResource(path);
    String contentType = Files.probeContentType(path);
    return ResponseEntity.ok()
      .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + name)
      .contentType(MediaType.parseMediaType(contentType==null?"application/octet-stream":contentType))
      .body(res);
  }
  @GetMapping("/files")
  public List<String> list(){
    File dir = new File(BASE_DIR); if (!dir.exists()) return List.of();
    return Arrays.stream(Objects.requireNonNull(dir.listFiles()))
      .filter(File::isFile).map(File::getName).collect(Collectors.toList());
  }
}
