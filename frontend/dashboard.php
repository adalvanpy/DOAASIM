<?php
require_once 'auth.php';

if (!isset($_SESSION['token'])) { 
    header('Location: login.php'); 
    exit(); 
}

$mensagem = '';
$sucesso = true;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['acao']) && $_POST['acao'] === 'candidatar') {
        $aparelho_id = intval($_POST['aparelho_id']);
        $payload = ['aparelho' => $aparelho_id];
        if (enviar_dados_api('candidaturas/', $payload, 'POST')) {
            $mensagem = "Candidatura registrada com sucesso!";
            $sucesso = true;
        } else {
            $mensagem = "Erro ao registrar candidatura.";
            $sucesso = false;
        }
    }
    
    if (isset($_POST['acao']) && ($_POST['acao'] === 'APROVADO' || $_POST['acao'] === 'NEGADO')) {
        $candidatura_id = intval($_POST['candidatura_id']);
        $payload = ['status' => $_POST['acao']];
        if (enviar_dados_api('candidaturas/' . $candidatura_id . '/', $payload, 'PATCH')) {
            $mensagem = "Status atualizado com sucesso!";
            $sucesso = true;
        } else {
            $mensagem = "Erro ao atualizar status.";
            $sucesso = false;
        }
    }
}

carregar_dados_api();

$username = $_SESSION['username'] ?? 'Usuário';
$user_type = $_SESSION['user_type'] ?? 'CANDIDATO'; 
$aparelhos = $_SESSION['aparelhos'] ?? [];
$candidaturas = $_SESSION['candidaturas'] ?? [];
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AASI - Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700;900&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #ffffff; }
        .card-shadow { box-shadow: 0 10px 30px -15px rgba(136, 160, 112, 0.2); }
    </style>
</head>
<body class="min-h-screen flex flex-col">

    <nav class="h-20 bg-white/80 backdrop-blur-md border-b border-gray-100 flex items-center justify-between px-12 z-50 sticky top-0">
        <div class="flex items-center gap-2">
            <span class="text-2xl font-black tracking-tighter text-[#88a070]">
              DO<span class="text-[#eeb47f]">AASI</span>M
            </span>
        </div>
        <div class="hidden md:flex items-center gap-8 text-[10px] font-black uppercase tracking-[0.2em] text-gray-400">
            <a href="index.php" class="hover:text-gray-900 transition">Início</a>
            <a href="dashboard.php" class="text-[#eeb47f]">Dashboard</a>
            <a href="sobre.php" class="hover:text-gray-900 transition">Sobre</a>
            <div class="h-4 w-[1px] bg-gray-200"></div>
            <div class="flex flex-col items-end leading-none">
                <span class="text-[12px] text-gray-900 mb-1"><?php echo htmlspecialchars($username); ?></span>
            </div>
            <a href="logout.php" class="bg-[#eeb47f] text-white px-6 py-2 rounded-full hover:bg-[#dda36e] transition shadow-lg shadow-orange-100">Sair</a>
        </div>
    </nav>

    <header class="bg-[#88a070] py-16 px-12 text-white border-b-8 border-[#eeb47f]">
        <div class="max-w-7xl mx-auto">
            <h1 class="text-5xl md:text-6xl font-black leading-none mb-4 italic tracking-tighter">Bem-vindo, <br><span class="text-[#fdfcf0]"><?php echo htmlspecialchars($username); ?>.</span></h1>
            <p class="text-white/60 text-[10px] font-black uppercase tracking-[0.4em]">Gestão centralizada de aparelhos auditivos</p>
        </div>
    </header>

    <main class="flex-grow w-full max-w-7xl mx-auto px-8 md:px-12 py-12">

        <?php if (!empty($mensagem)): ?>
            <div class="mb-10 p-5 rounded-sm border-l-8 font-black text-[10px] uppercase tracking-widest <?php echo $sucesso ? 'bg-green-50 border-[#88a070] text-[#88a070]' : 'bg-red-50 border-red-400 text-red-700'; ?>">
                <?php echo htmlspecialchars($mensagem); ?>
            </div>
        <?php endif; ?>

        <?php if ($user_type === 'EMPRESA'): ?>
            <div class="space-y-8">
                <h2 class="text-3xl font-black text-gray-900 tracking-tighter uppercase">Fila de Candidaturas</h2>
                <?php if (empty($candidaturas)): ?>
                    <div class="bg-white p-16 text-center border-2 border-dashed border-gray-100 text-gray-400 font-bold uppercase tracking-widest text-xs">Sem novas solicitações.</div>
                <?php else: ?>
                    <div class="bg-white border border-gray-100 card-shadow overflow-hidden">
                        <table class="w-full text-left">
                            <thead class="bg-gray-50 text-[10px] font-black uppercase tracking-[0.2em] text-gray-400 border-b">
                                <tr>
                                    <th class="px-8 py-5">Candidato</th>
                                    <th class="px-8 py-5">Aparelho</th>
                                    <th class="px-8 py-5">Status</th>
                                    <th class="px-8 py-5 text-right">Ação</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-50">
                                <?php foreach ($candidaturas as $c): ?>
                                <tr class="hover:bg-gray-50/50 transition">
                                    <td class="px-8 py-5 font-bold text-gray-900 uppercase text-xs"><?php echo htmlspecialchars($c['candidato_nome'] ?? '—'); ?></td>
                                    <td class="px-8 py-5 text-gray-500 text-xs italic"><?php echo htmlspecialchars($c['aparelho_nome'] ?? '—'); ?></td>
                                    <td class="px-8 py-5">
                                        <span class="text-[9px] font-black px-3 py-1 border <?php echo ($c['status'] === 'APROVADO') ? 'border-[#88a070] text-[#88a070]' : 'border-[#eeb47f] text-[#eeb47f]'; ?>">
                                            <?php echo $c['status']; ?>
                                        </span>
                                    </td>
                                    <td class="px-8 py-5 text-right">
                                        <form method="POST" class="inline-flex gap-2">
                                            <input type="hidden" name="candidatura_id" value="<?php echo $c['id']; ?>">
                                            <button name="acao" value="APROVADO" class="bg-[#88a070] text-white px-4 py-2 text-[9px] font-black uppercase tracking-widest hover:bg-[#768a61] transition">Aprovar</button>
                                            <button name="acao" value="NEGADO" class="bg-white border border-gray-200 text-gray-400 px-4 py-2 text-[9px] font-black uppercase tracking-widest hover:bg-red-50 hover:text-red-400 transition">Negar</button>
                                        </form>
                                    </td>
                                </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                <?php endif; ?>
            </div>
        <?php endif; ?>

        <?php if ($user_type === 'DOADOR'): ?>
            <div class="flex flex-col md:flex-row gap-12">
                <div class="flex-grow">
                    <h2 class="text-3xl font-black text-gray-900 mb-8 tracking-tighter uppercase">Minhas Doações</h2>
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                        <?php foreach ($aparelhos as $a): ?>
                        <div class="bg-white p-6 border border-gray-100 flex items-center gap-6 card-shadow">
                            <div class="w-14 h-14 bg-[#88a070] flex items-center justify-center text-white shrink-0">
                                <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M5 13l4 4L19 7"></path></svg>
                            </div>
                            <div>
                                <h4 class="text-sm font-black uppercase text-gray-900 mb-1"><?php echo htmlspecialchars($a['nome']); ?></h4>
                                <p class="text-[10px] text-[#eeb47f] font-black uppercase tracking-[0.2em]"><?php echo htmlspecialchars($a['marca']); ?></p>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                </div>
                <div class="w-full md:w-96 shrink-0">
                    <div class="bg-[#eeb47f] p-10 shadow-2xl">
                        <h3 class="text-white text-3xl font-black italic mb-6 leading-none">Cadastrar <br>Aparelho</h3>
                        <p class="text-white/80 text-xs mb-8 leading-relaxed font-light">Sua contribuição é o primeiro passo para a inclusão de um novo aluno.</p>
                        <a href="doar_aparelho.php" class="block w-full text-center bg-white text-[#eeb47f] py-4 text-xs font-black uppercase tracking-[0.3em] hover:bg-[#88a070] hover:text-white transition-all">Iniciar Processo —></a>
                    </div>
                </div>
            </div>
        <?php endif; ?>

        <?php if ($user_type === 'CANDIDATO'): ?>
            <div class="mb-10">
                <h2 class="text-4xl font-black text-gray-900 tracking-tighter uppercase mb-10">Modelos <span class="text-[#eeb47f]">Disponíveis</span></h2>
                
                <div class="grid grid-cols-1 md:grid-cols-3 gap-10">
                    <?php foreach ($aparelhos as $a): ?>
                    <?php 
                        $inscrito = false;
                        $status = '';
                        foreach ($candidaturas as $cand) {
                            if ((int)$cand['aparelho'] === (int)$a['id']) { $inscrito = true; $status = $cand['status']; break; }
                        }
                    ?>
                    <div class="bg-white border border-gray-100 card-shadow flex flex-col group relative">
                        <?php if($inscrito): ?>
                            <div class="absolute top-4 right-4 z-10 bg-[#88a070] text-white text-[8px] font-black px-3 py-1 uppercase tracking-widest shadow-lg"><?php echo $status; ?></div>
                        <?php endif; ?>

                        <div class="h-56 bg-[#f9f9f2] p-10 flex items-center justify-center overflow-hidden">
                            <img src="<?php echo !empty($a['imagem']) ? $a['imagem'] : 'https://via.placeholder.com/150'; ?>" class="max-h-full grayscale group-hover:grayscale-0 transition-all duration-700 transform group-hover:scale-110">
                        </div>
                        <div class="p-8">
                            <span class="text-[9px] font-black text-[#eeb47f] uppercase tracking-[0.2em] mb-2 block"><?php echo htmlspecialchars($a['marca']); ?></span>
                            <h3 class="text-xl font-black text-gray-900 mb-6 leading-tight"><?php echo htmlspecialchars($a['nome']); ?></h3>
                            
                            <div class="space-y-3 mb-8 text-[10px] font-bold uppercase tracking-widest text-gray-400">
                                <div class="flex justify-between border-b border-gray-50 pb-2">
                                    <span>Grau</span>
                                    <span class="text-gray-900"><?php echo htmlspecialchars($a['perda_indicada'] ?? 'N/A'); ?></span>
                                </div>
                                <div class="flex justify-between border-b border-gray-50 pb-2">
                                    <span>Modelo</span>
                                    <span class="text-gray-900"><?php echo htmlspecialchars($a['modelo_display'] ?? $a['modelo'] ?? '—'); ?></span>
                                </div>
                            </div>

                            <?php if(!$inscrito): ?>
                                <form method="POST">
                                    <input type="hidden" name="acao" value="candidatar">
                                    <input type="hidden" name="aparelho_id" value="<?php echo $a['id']; ?>">
                                    <button class="w-full bg-[#88a070] text-white py-4 text-[10px] font-black uppercase tracking-[0.2em] hover:bg-black transition-all shadow-lg shadow-green-100">Solicitar Aparelho</button>
                                </form>
                            <?php else: ?>
                                <div class="w-full text-center py-4 text-[10px] font-black uppercase tracking-[0.2em] border border-gray-100 text-gray-300 select-none">Candidatura Enviada</div>
                            <?php endif; ?>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>
        <?php endif; ?>

    </main>

    <footer class="p-12 text-center border-t border-gray-100 mt-auto bg-white">
        <p class="text-[9px] font-black text-gray-400 uppercase tracking-[0.4em]">AASI — 2026 — Gestão de Apoio Auditivo Institucional</p>
    </footer>

</body>
</html>