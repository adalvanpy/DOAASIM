<?php
require_once 'auth.php';
// Tenta carregar dados se o usuário estiver logado para mostrar números reais, 
// caso contrário, mostra números fictícios.
$qtd_aparelhos = isset($_SESSION['aparelhos']) ? count($_SESSION['aparelhos']) : 124;
$qtd_candidatos = isset($_SESSION['candidaturas']) ? count($_SESSION['candidaturas']) : 85;
$qtd_doadores = 42; // Exemplo estático ou vindo de uma contagem de perfis tipo DOADOR
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AASI - Início</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;700;900&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .bg-custom-pattern {
            background-image: linear-gradient(rgba(0,0,0,0.75), rgba(0,0,0,0.75)), url('https://images.unsplash.com/photo-1584515933487-779824d29309?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');
            background-size: cover;
            background-position: center;
        }
    </style>
</head>
<body class="bg-[#fdfcf0] min-h-screen flex flex-col overflow-x-hidden">

    <nav class="h-20 bg-white/90 backdrop-blur-md border-b border-gray-100 flex items-center justify-between px-12 z-50 fixed w-full">
        <div class="flex items-center gap-2">
            <span class="text-2xl font-black tracking-tighter text-[#88a070]">
              DO<span class="text-[#eeb47f]">AASI</span>M
            </span>
        </div>
        <div class="hidden md:flex items-center gap-8 text-[10px] font-black uppercase tracking-[0.2em] text-gray-400">
            <a href="index.php" class="text-[#eeb47f]">Início</a>
            <a href="dashboard.php" class="hover:text-gray-900 transition">Dashboard</a>
            <a href="sobre.php" class="hover:text-gray-900 transition">Sobre</a>
            <?php if(!isset($_SESSION['token'])): ?>
                <a href="login.php" class="bg-[#88a070] text-white px-8 py-3 rounded-full hover:bg-[#768a61] transition shadow-lg shadow-green-100">Login</a>
            <?php else: ?>
                <a href="logout.php" class="text-red-400 hover:text-red-600">Sair</a>
            <?php endif; ?>
        </div>
    </nav>

    <main class="flex-grow flex flex-col md:flex-row pt-20">
        
        <div class="relative w-full md:w-3/4 bg-custom-pattern p-8 md:p-20 flex flex-col justify-center">
            
            <div class="max-w-5xl mx-auto w-full">
                <div class="mb-16">
                    <h1 class="text-white text-6xl md:text-7xl font-black leading-[0.9] mb-6">
                        Tecnologia <br> <span class="text-[#eeb47f]">Acessível.</span>
                    </h1>
                    <p class="text-gray-400 text-lg max-w-md font-light leading-relaxed">
                        Transformando o silêncio em oportunidades através da doação de aparelhos auditivos.
                    </p>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-3 gap-6 mb-16">
                    <div class="border-l-2 border-[#88a070] pl-6 py-2">
                        <span class="block text-4xl font-black text-white"><?php echo $qtd_aparelhos; ?></span>
                        <span class="text-[10px] uppercase font-bold tracking-widest text-[#88a070]">Aparelhos Doados</span>
                    </div>
                    <div class="border-l-2 border-[#eeb47f] pl-6 py-2">
                        <span class="block text-4xl font-black text-white"><?php echo $qtd_candidatos; ?></span>
                        <span class="text-[10px] uppercase font-bold tracking-widest text-[#eeb47f]">Candidatos Ativos</span>
                    </div>
                    <div class="border-l-2 border-white/20 pl-6 py-2">
                        <span class="block text-4xl font-black text-white"><?php echo $qtd_doadores; ?></span>
                        <span class="text-[10px] uppercase font-bold tracking-widest text-gray-500">Doadores Parceiros</span>
                    </div>
                </div>

                <div class="flex flex-wrap gap-4">
                    <a href="login.php" class="bg-[#eeb47f] text-white px-10 py-5 rounded-sm font-black uppercase text-xs tracking-[0.2em] hover:bg-[#dda36e] transition-all transform hover:-translate-y-1">
                        Quero me Candidatar
                    </a>
                    <a href="login.php" class="bg-transparent border border-white/30 text-white px-10 py-5 rounded-sm font-black uppercase text-xs tracking-[0.2em] hover:bg-white hover:text-black transition-all">
                        Quero Doar
                    </a>
                </div>
            </div>

            <div class="absolute right-0 top-1/2 -translate-y-1/2 translate-x-1/2 hidden xl:block w-80 bg-[#88a070] p-12 shadow-2xl border-l-8 border-[#eeb47f]">
                <h3 class="text-white text-2xl font-bold italic mb-4">Inclusão <br>Auditiva</h3>
                <p class="text-white/70 text-xs leading-relaxed mb-6">
                    Nosso sistema valida automaticamente compatibilidades de perda auditiva para agilizar o processo de entrega.
                </p>
                <div class="w-12 h-[2px] bg-[#eeb47f]"></div>
            </div>
        </div>

        <div class="hidden md:block w-1/4 bg-[#eeb47f] relative overflow-hidden">
            <div class="absolute inset-0 flex items-center justify-center">
                <span class="rotate-90 text-[140px] font-black text-black/5 select-none tracking-tighter">SUPPORT</span>
            </div>
            
            <div class="absolute bottom-12 left-1/2 -translate-x-1/2 rotate-90 whitespace-nowrap">
                <a href="#" class="text-[10px] font-black uppercase tracking-[0.3em] text-white hover:text-black transition">Nossos Valores —></a>
            </div>
        </div>

    </main>

    <footer class="bg-white py-8 px-12 flex flex-col md:flex-row justify-between items-center border-t border-gray-100">
        <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest">© 2026 AASI System - Inclusão de Alunos</p>
        <div class="flex gap-6 mt-4 md:mt-0">
            <span class="w-2 h-2 rounded-full bg-[#88a070]"></span>
            <span class="w-2 h-2 rounded-full bg-[#eeb47f]"></span>
            <span class="w-2 h-2 rounded-full bg-gray-200"></span>
        </div>
    </footer>

</body>
</html>