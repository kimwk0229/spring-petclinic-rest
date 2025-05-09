//아래 JUnit, Rest Assured 코드를 JMeter DSL java 코드로 변환해줘
package org.springframework.samples.petclinic;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import org.junit.jupiter.api.*;

import static org.hamcrest.Matchers.*;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class) // 테스트 순서 지정
class PetClinicScenarioTest {

    private static String baseUrl = "http://localhost:9966/petclinic";
    private static int ownerId;
    private static int petId;
    private static int visitId;

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = baseUrl;
    }

    @Test
    @Order(1)
    void 주인_등록() {
        Response response = RestAssured.given()
            .contentType(ContentType.JSON)
            .body("""
                {
                  "address": "sungdong",
                  "city": "seoul",
                  "firstName": "gildong",
                  "lastName": "hong",
                  "telephone": "01022223333"
                }
            """)
        .when()
            .post("/api/owners")
        .then()
            .statusCode(201)
            .body("id", notNullValue())
            .body("firstName", equalTo("gildong"))
        .extract()
            .response();

        ownerId = response.jsonPath().getInt("id");
    }

    @Test
    @Order(2)
    void 애완동물_등록() {

        Response response = RestAssured.given()
            .contentType(ContentType.JSON)
            .body("""
                {
                  "birthDate": "2025-12-04",
                  "name": "dongdong",
                  "type": {
                    "id": 1,
                    "name": "cat"
                  }
                }
            """)
        .when()
            .post("/api/owners/" + ownerId + "/pets")
        .then()
            .statusCode(201)
            .body("id", notNullValue())
            .body("ownerId", equalTo(ownerId))
        .extract()
            .response();

        petId = response.jsonPath().getInt("id");
    }

    @Test
    @Order(3)
    void 방문_일정_등록() {

        Response response = RestAssured.given()
            .contentType(ContentType.JSON)
            .body("""
                {
                  "description": "regular checkup",
                  "date": "2025-05-12"
                }
            """)
        .when()
            .post("/api/owners/" + ownerId + "/pets/" + petId + "/visits")
        .then()
            .statusCode(201)
            .body("id", notNullValue())
            .body("petId", equalTo(petId))
        .extract()
            .response();

        visitId = response.jsonPath().getInt("id");
    }

    @Test
    @Order(4)
    void 방문_일정_조회() {
        RestAssured.given()
            .contentType(ContentType.JSON)
        .when()
            .get("/api/visits/" + visitId)
        .then()
            .statusCode(200)
            .body("id", equalTo(visitId))
            .body("petId", equalTo(petId))
            .body("date", matchesPattern("^\\d{4}-\\d{2}-\\d{2}$"));
    }
}
