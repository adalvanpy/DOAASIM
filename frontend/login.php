<?php
require_once 'auth.php';

// Se já estiver logado, joga direto para o painel
if (isset($_SESSION['token'])) {
    header('Location: dashboard.php');
    exit();
}

$erro = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username']);
    $password = trim($_POST['password']);

    if (!empty($username) && !empty($password)) {
        $resultado = login($username, $password);
        
        if ($resultado === true) {
            header('Location: dashboard.php');
            exit();
        } else {
            $erro = $resultado; // Armazena a string de erro retornada pela função
        }
    } else {
        $erro = "Por favor, preencha todos os campos.";
    }
}
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AASI - Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="bg-slate-100 min-h-screen flex items-center justify-center p-4">

    <div class="bg-white p-8 rounded-2xl shadow-xl border border-gray-200 w-full max-w-md">
        <div class="text-center mb-8">
            <span class="text-3xl font-black text-blue-600 tracking-tight">AASI</span>
            <p class="text-gray-500 text-sm mt-2">Sistema de Apoio ao Aluno com Deficiência Auditiva</p>
        </div>

        <?php if (!empty($erro)): ?>
            <div class="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-xl text-sm font-semibold mb-4 text-center">
                <?php echo htmlspecialchars($erro); ?>
            </div>
        <?php endif; ?>

        <form method="POST" action="login.php" class="space-y-5">
            <div>
                <label class="block text-xs font-bold uppercase tracking-wide text-gray-500 mb-2">Usuário</label>
                <input type="text" name="username" required placeholder="Digite seu usuário"
                       class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:border-blue-500 text-sm transition">
            </div>

            <div>
                <label class="block text-xs font-bold uppercase tracking-wide text-gray-500 mb-2">Senha</label>
                <input type="password" name="password" required placeholder="••••••••"
                       class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:border-blue-500 text-sm transition">
            </div>

            <button type="submit" 
                    class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 rounded-xl text-sm shadow-lg shadow-blue-100 transition uppercase tracking-wider">
                Entrar no Sistema
            </button>
        </form>
    </div>

</body>
</html>