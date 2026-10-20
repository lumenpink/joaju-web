use axum::body::Body;
use axum::http::{Request, StatusCode};
use http_body_util::BodyExt;
use joaju_web::create_app;
use serde_json::Value;
use tower::ServiceExt;

#[tokio::test]
async fn test_spec_health_endpoint() {
    let app = create_app();

    let response = app
        .oneshot(
            Request::builder()
                .uri("/health")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);

    // Header CORS presente
    let cors_header = response.headers().get("access-control-allow-origin");
    assert!(cors_header.is_some(), "Header CORS deve estar presente");
    assert_eq!(cors_header.unwrap(), "*");

    let body = response.into_body().collect().await.unwrap().to_bytes();
    let json: Value = serde_json::from_slice(&body).expect("JSON válido no health check");

    assert_eq!(json["status"], "ok");
    assert_eq!(json["name"], "joaju");
    let expected_version = include_str!("../VERSION").trim();
    assert_eq!(json["version"], expected_version);
    assert!(json["uptime"].is_number());
}

#[tokio::test]
async fn test_spec_cors_preflight_options() {
    let app = create_app();

    let response = app
        .oneshot(
            Request::builder()
                .method("OPTIONS")
                .uri("/health")
                .header("Origin", "http://localhost:3000")
                .header("Access-Control-Request-Method", "GET")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert!(
        response.status().is_success(),
        "Preflight OPTIONS deve retornar sucesso"
    );
    let cors_header = response.headers().get("access-control-allow-origin");
    assert!(cors_header.is_some());
}

#[tokio::test]
async fn test_spec_static_locales_route() {
    let app = create_app();

    let response = app
        .oneshot(
            Request::builder()
                .uri("/locales/pt.json")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
    let body = response.into_body().collect().await.unwrap().to_bytes();
    let json: Value = serde_json::from_slice(&body).expect("Arquivo pt.json deve ser JSON válido");
    assert!(json.is_object());
}

#[tokio::test]
async fn test_mutation_health_uptime_is_non_negative() {
    let app = create_app();

    let response = app
        .oneshot(
            Request::builder()
                .uri("/health")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    let body = response.into_body().collect().await.unwrap().to_bytes();
    let json: Value = serde_json::from_slice(&body).unwrap();
    let uptime = json["uptime"].as_f64().unwrap();
    assert!(uptime >= 0.0);
}

#[tokio::test]
async fn test_spec_compile_endpoint() {
    let app = create_app();

    let payload = serde_json::json!({
        "markdown": "# Test Document\n\nHello world from Axum server.",
        "template": "manuscript"
    });

    let response = app
        .oneshot(
            Request::builder()
                .method("POST")
                .uri("/compile")
                .header("Content-Type", "application/json")
                .body(Body::from(payload.to_string()))
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
    assert_eq!(
        response.headers().get("content-type").unwrap(),
        "application/pdf"
    );
    let bytes = response.into_body().collect().await.unwrap().to_bytes();
    assert!(bytes.starts_with(b"%PDF-"));
}

#[tokio::test]
async fn test_spec_compile_empty_bad_request() {
    let app = create_app();

    let payload = serde_json::json!({
        "markdown": "   "
    });

    let response = app
        .oneshot(
            Request::builder()
                .method("POST")
                .uri("/compile")
                .header("Content-Type", "application/json")
                .body(Body::from(payload.to_string()))
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::BAD_REQUEST);
}

#[tokio::test]
async fn test_spec_render_pedigree_endpoint() {
    let app = create_app();

    let payload = serde_json::json!({
        "format": "pedtools",
        "code": "1 0 0 1 1\n"
    });

    let response = app
        .oneshot(
            Request::builder()
                .method("POST")
                .uri("/render")
                .header("Content-Type", "application/json")
                .body(Body::from(payload.to_string()))
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
    let bytes = response.into_body().collect().await.unwrap().to_bytes();
    let json: Value = serde_json::from_slice(&bytes).unwrap();
    assert_eq!(json["format"], "pedtools");
    assert!(json["svg"].as_str().unwrap().contains("<svg"));
}

#[tokio::test]
async fn test_spec_render_chem_endpoint() {
    let app = create_app();

    let payload = serde_json::json!({
        "format": "openchemlib",
        "code": "CCO"
    });

    let response = app
        .oneshot(
            Request::builder()
                .method("POST")
                .uri("/render")
                .header("Content-Type", "application/json")
                .body(Body::from(payload.to_string()))
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
    let bytes = response.into_body().collect().await.unwrap().to_bytes();
    let json: Value = serde_json::from_slice(&bytes).unwrap();
    assert_eq!(json["format"], "openchemlib");
    assert!(json["svg"].as_str().unwrap().contains("<svg"));
}

#[tokio::test]
async fn test_spec_preprocess_endpoint() {
    let app = create_app();

    let payload = serde_json::json!({
        "markdown": "# Header\n\nSome text"
    });

    let response = app
        .oneshot(
            Request::builder()
                .method("POST")
                .uri("/preprocess")
                .header("Content-Type", "application/json")
                .body(Body::from(payload.to_string()))
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
    let body = response.into_body().collect().await.unwrap().to_bytes();
    let json: Value = serde_json::from_slice(&body).unwrap();
    assert_eq!(json["markdown"], "# Header\n\nSome text");
}

#[tokio::test]
async fn test_spec_unfurl_invalid_url() {
    let app = create_app();

    let payload = serde_json::json!({
        "url": "ftp://not-allowed.org"
    });

    let response = app
        .oneshot(
            Request::builder()
                .method("POST")
                .uri("/unfurl")
                .header("Content-Type", "application/json")
                .body(Body::from(payload.to_string()))
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::BAD_REQUEST);
}

#[tokio::test]
async fn test_spec_render_table_endpoint() {
    let app = create_app();

    let payload = serde_json::json!({
        "format": "table",
        "code": "A | B\n1 | 2"
    });

    let response = app
        .oneshot(
            Request::builder()
                .method("POST")
                .uri("/render")
                .header("Content-Type", "application/json")
                .body(Body::from(payload.to_string()))
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
    let bytes = response.into_body().collect().await.unwrap().to_bytes();
    let json: Value = serde_json::from_slice(&bytes).unwrap();
    assert_eq!(json["format"], "table");
    assert_eq!(json["type"], "html");
    assert!(json["svg"]
        .as_str()
        .unwrap()
        .contains("joaju-academic-table"));
}
