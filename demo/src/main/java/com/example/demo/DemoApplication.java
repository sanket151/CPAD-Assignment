package com.example.demo;

import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import com.example.demo.model.Person;
import com.example.demo.repository.PersonRepository;

@SpringBootApplication
public class DemoApplication {

	public static void main(String[] args) {
		SpringApplication.run(DemoApplication.class, args);
	}

	@Autowired
	private PersonRepository personRepository;

	// @Bean
	// InitializingBean sendPersonData() {
	// 	return () -> {
	// 		personRepository.save(new Person("Sanket","Male","Admin",toDate));
	// 		personRepository.save(new Person("Jimmy","Male","Student"));
	// 	};
	// }
}
