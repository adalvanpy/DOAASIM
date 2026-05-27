<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

/**
 * Realiza o login consumindo o container 'api' do Django
 */
function login($username, $password) {
    $url = 'http://api:8000/api/token/'; 

    $data = [
        'username' => $username,
        'password' => $password
    ];

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json'
    ]);
    curl_setopt($ch, CURLOPT_TIMEOUT, 5); 

    $result = curl_exec($ch);
    $error = curl_error($ch);
    curl_close($ch);
    
    if ($error) {
        return "Erro de rede Docker: O container PHP não encontrou o container API. Detalhe: " . $error;
    }

    $response = json_decode($result, true);

    if (isset($response['access'])) {
        $_SESSION['token'] = $response['access'];
        $_SESSION['refresh'] = $response['refresh'];

        $perfil_carregado = carregar_perfil_usuario($username);
        
        if (!$perfil_carregado) {
            $_SESSION['username'] = $username;
            $_SESSION['user_type'] = 'CANDIDATO'; 
        }

        carregar_dados_api();
        return true;
    }

    return $response['detail'] ?? "Credenciais inválidas no servidor Django.";
}

/**
 * Busca e valida o perfil do usuário logado de acordo com a estrutura do seu JSON
 */
function carregar_perfil_usuario($username_digitado) {
    $perfis = buscar_dados_api('profiles/'); 

    if (!empty($perfis) && is_array($perfis)) {
        foreach ($perfis as $perfil) {
            if (isset($perfil['user_details']['username'])) {
                if (strtolower($perfil['user_details']['username']) === strtolower($username_digitado)) {
                    $_SESSION['username']  = $perfil['user_details']['username'];
                    $_SESSION['user_type'] = $perfil['tipo']; 
                    $_SESSION['perfil_id'] = $perfil['id'];
                    return true;
                }
            }
        }
    }
    return false;
}

/**
 * Função utilitária em cURL para requisições GET autenticadas
 */
function buscar_dados_api($endpoint) {
    if (!isset($_SESSION['token'])) return [];

    $url = 'http://api:8000/api/' . $endpoint;
    
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $_SESSION['token'],
        'Content-Type: application/json'
    ]);
    curl_setopt($ch, CURLOPT_TIMEOUT, 5);

    $result = curl_exec($ch);
    curl_close($ch);
    
    if ($result === FALSE) return [];
    
    $dados = json_decode($result, true);
    return is_array($dados) ? $dados : [];
}

/**
 * Função utilitária em cURL para requisições POST, PATCH ou PUT autenticadas
 */
function enviar_dados_api($endpoint, $dados, $metodo = 'POST') {
    if (!isset($_SESSION['token'])) return false;

    $url = 'http://api:8000/api/' . $endpoint;
    
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $metodo);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($dados));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $_SESSION['token'],
        'Content-Type: application/json'
    ]);
    curl_setopt($ch, CURLOPT_TIMEOUT, 5);

    $result = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($http_code >= 200 && $http_code < 300) {
        return true;
    }
    
    return false;
}

/**
 * Sincroniza os arrays do Dashboard contornando possíveis retornos nulos
 */
function carregar_dados_api() {
    $aparelhos = buscar_dados_api('devices/'); 
    $candidaturas = buscar_dados_api('candidaturas/');

    $_SESSION['aparelhos'] = is_array($aparelhos) ? $aparelhos : [];
    $_SESSION['candidaturas'] = is_array($candidaturas) ? $candidaturas : [];
}

