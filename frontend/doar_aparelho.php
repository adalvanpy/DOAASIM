<?php
require_once 'auth.php';

// Proteção da página: Expulsa se não houver Token armazenado na sessão
if (!isset($_SESSION['token'])) { 
    header('Location: login.php'); 
    exit(); 
}

$mensagem = '';
$sucesso = true;

// ================= PROCESSAMENTO DE AÇÕES (POST) =================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    
    // Ação 1: Candidato se candidatar a um aparelho
    if (isset($_POST['acao']) && $_POST['acao'] === 'candidatar') {
        $aparelho_id = intval($_POST['aparelho_id']);
        
        $payload = [
            'aparelho' => $aparelho_id
        ];
        
        if (enviar_dados_api('candidaturas/', $payload, 'POST')) {
            $mensagem = "Candidatura registrada com sucesso!";
            $sucesso = true;
        } else {
            $mensagem = "Erro ao registrar candidatura. Verifique se os requisitos foram preenchidos.";
            $sucesso = false;
        }
    }
    
    // Ação 2: Empresa aprovar ou negar candidatura
    if (isset($_POST['acao']) && ($_POST['acao'] === 'APROVADO' || $_POST['acao'] === 'NEGADO')) {
        $candidatura_id = intval($_POST['candidatura_id']);
        $novo_status = $_POST['acao'];
        
        $payload = [
            'status' => $novo_status
        ];
        
        if (enviar_dados_api('candidaturas/' . $candidatura_id . '/', $payload, 'PATCH')) {
            $mensagem = "Candidatura atualizada para " . $novo_status . " com sucesso!";
            $sucesso = true;
        } else {
            $mensagem = "Não foi possível alterar o status da candidatura.";
            $sucesso = false;
        }
    }
}

// Força a atualização dos dados vindos da API Django ao atualizar o painel
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
    <title>AASI - Painel de Controle</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="bg-slate-50 min-h-screen flex">

    <!-- ================= SIDEBAR LATERAL ================= -->
    <aside class="w-64 bg-white border-r border-gray-200 flex flex-col fixed h-full z-50">
        <!-- Brand / Logo -->
        <div class="h-16 flex items-center px-6 border-b border-gray-100 gap-3">
            <span class="text-2xl font-black text-blue-600 tracking-tight">AASI</span>
            <span class="text-[10px] font-bold uppercase tracking-widest text-gray-400 bg-gray-50 px-2 py-0.5 rounded">v1.0</span>
        </div>

        <!-- Menu de Navegação -->
        <nav class="flex-grow p-4 space-y-1.5 overflow-y-auto">
            <span class="block px-3 text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-2">Navegação</span>
            
            <a href="index.php" class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-semibold text-gray-600 hover:bg-gray-50 hover:text-gray-900 transition">
                <svg class="w-5 h-5 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path></svg>
                Início (Index)
            </a>

            <a href="dashboard.php" class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-bold text-blue-600 bg-blue-50/70 transition">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 8v8m-4-5v5m-4-2v2m-2 4h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                Dashboard
            </a>

            <a href="sobre.php" class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-semibold text-gray-600 hover:bg-gray-50 hover:text-gray-900 transition">
                <svg class="w-5 h-5 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                Sobre o Sistema
            </a>
        </nav>

        <!-- Rodapé da Sidebar: Info do Usuário + Sair -->
        <div class="p-4 border-t border-gray-100 bg-gray-50/50">
            <div class="flex items-center justify-between mb-3 px-2">
                <div class="overflow-hidden pr-2">
                    <p class="text-sm font-bold text-gray-900 truncate"><?php echo htmlspecialchars($username); ?></p>
                    <p class="text-[10px] text-blue-500 font-bold uppercase tracking-wider truncate"><?php echo htmlspecialchars($user_type); ?></p>
                </div>
            </div>
            <a href="logout.php" class="w-full flex items-center justify-center gap-2 bg-red-50 hover:bg-red-100 text-red-600 py-2.5 rounded-xl text-xs font-bold transition uppercase tracking-wider">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>
                Sair da conta
            </a>
        </div>
    </aside>

    <!-- ================= CONTEÚDO PRINCIPAL (À DIREITA) ================= -->
    <div class="flex-grow pl-64 flex flex-col min-h-screen">
        
        <main class="flex-grow w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">

            <!-- Retorno de Feedback Visual para Operações -->
            <?php if (!empty($mensagem)): ?>
                <div class="mb-6 p-4 rounded-xl font-semibold text-sm border <?php echo $sucesso ? 'bg-green-50 border-green-200 text-green-700' : 'bg-red-50 border-red-200 text-red-700'; ?>">
                    <?php echo htmlspecialchars($mensagem); ?>
                </div>
            <?php endif; ?>

            <!-- ================= VISÃO: EMPRESA ================= -->
            <?php if ($user_type === 'EMPRESA'): ?>
                <div class="mb-8">
                    <h1 class="text-2xl font-bold text-gray-900">Gestão de Candidaturas</h1>
                    <p class="text-gray-500">Analise os pedidos e aprove as doações para os alunos.</p>
                </div>

                <?php if (empty($candidaturas)): ?>
                    <div class="bg-white p-8 rounded-2xl border border-gray-200 text-center text-gray-500">
                        Nenhuma candidatura aguardando análise no momento.
                    </div>
                <?php else: ?>
                    <div class="bg-white shadow-sm border border-gray-200 rounded-2xl overflow-hidden">
                        <div class="overflow-x-auto">
                            <table class="w-full text-left border-collapse">
                                <thead class="bg-gray-50 border-b border-gray-200 text-gray-400 text-[10px] uppercase tracking-widest font-bold">
                                    <tr>
                                        <th class="px-6 py-4">Candidato</th>
                                        <th class="px-6 py-4">Aparelho</th>
                                        <th class="px-6 py-4 text-center">Laudo Técnico</th>
                                        <th class="px-6 py-4">Status</th>
                                        <th class="px-6 py-4 text-right">Ações</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-100 text-sm">
                                    <?php foreach ($candidaturas as $c): ?>
                                    <tr class="hover:bg-gray-50 transition">
                                        <td class="px-6 py-4 font-semibold text-gray-900"><?php echo htmlspecialchars($c['candidato_nome'] ?? 'Não informado'); ?></td>
                                        <td class="px-6 py-4 text-gray-600"><?php echo htmlspecialchars($c['aparelho_nome'] ?? 'Não informado'); ?></td>
                                        <td class="px-6 py-4 text-center">
                                            <?php if(!empty($c['laudo_exame'])): ?>
                                                <a href="<?php echo $c['laudo_exame']; ?>" target="_blank" class="inline-flex items-center text-blue-600 hover:underline gap-1 font-medium">
                                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path></svg>
                                                    Ver PDF
                                                </a>
                                            <?php else: ?>
                                                <span class="text-gray-400 text-xs">Sem arquivo</span>
                                            <?php endif; ?>
                                        </td>
                                        <td class="px-6 py-4">
                                            <span class="px-2 py-1 rounded-md text-[10px] font-black uppercase <?php echo ($c['status'] === 'APROVADO') ? 'bg-green-100 text-green-700' : (($c['status'] === 'NEGADO') ? 'bg-red-100 text-red-700' : 'bg-amber-100 text-amber-700'); ?>">
                                                <?php echo htmlspecialchars($c['status'] ?? 'AGUARDANDO'); ?>
                                            </span>
                                        </td>
                                        <td class="px-6 py-4 text-right space-x-2 whitespace-nowrap">
                                            <?php if (($c['status'] ?? 'AGUARDANDO') === 'AGUARDANDO'): ?>
                                                <form method="POST" class="inline-block">
                                                    <input type="hidden" name="candidatura_id" value="<?php echo $c['id']; ?>">
                                                    <input type="hidden" name="acao" value="APROVADO">
                                                    <button type="submit" class="bg-green-600 text-white px-3 py-1.5 rounded-lg text-xs font-bold hover:bg-green-700 transition">Aprovar</button>
                                                </form>
                                                <form method="POST" class="inline-block">
                                                    <input type="hidden" name="candidatura_id" value="<?php echo $c['id']; ?>">
                                                    <input type="hidden" name="acao" value="NEGADO">
                                                    <button type="submit" class="text-red-500 hover:bg-red-50 px-3 py-1.5 rounded-lg text-xs font-bold transition">Negar</button>
                                                </form>
                                            <?php else: ?>
                                                <span class="text-gray-400 text-xs italic">Finalizado</span>
                                            <?php endif; ?>
                                        </td>
                                    </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    </div>
                <?php endif; ?>
            <?php endif; ?>

            <!-- ================= VISÃO: DOADOR ================= -->
            <?php if ($user_type === 'DOADOR'): ?>
                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    <div class="lg:col-span-2">
                        <h2 class="text-xl font-bold text-gray-900 mb-4">Meus Aparelhos Doados</h2>
                        
                        <?php if (empty($aparelhos)): ?>
                            <div class="bg-white p-6 rounded-xl border border-gray-200 text-center text-gray-400 text-sm">
                                Você ainda não cadastrou nenhuma doação.
                            </div>
                        <?php else: ?>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <?php foreach ($aparelhos as $a): ?>
                                <div class="bg-white p-4 rounded-xl border border-gray-200 shadow-sm flex items-center gap-4">
                                    <img src="<?php echo !empty($a['imagem']) ? $a['imagem'] : 'https://via.placeholder.com/150'; ?>" class="w-16 h-16 object-contain bg-gray-50 rounded-lg p-2" alt="">
                                    <div>
                                        <h4 class="font-bold text-gray-800 uppercase text-sm"><?php echo htmlspecialchars($a['nome']); ?></h4>
                                        <p class="text-xs text-gray-500"><?php echo htmlspecialchars($a['marca']); ?></p>
                                        <span class="mt-2 inline-block text-[9px] font-bold px-2 py-0.5 rounded bg-green-100 text-green-700 uppercase">
                                            Ativo
                                        </span>
                                    </div>
                                </div>
                                <?php endforeach; ?>
                            </div>
                        <?php endif; ?>
                    </div>
                    
                    <div class="bg-blue-600 rounded-2xl p-6 text-white shadow-xl shadow-blue-100 flex flex-col justify-between h-48 lg:h-auto">
                        <div>
                            <h3 class="text-xl font-bold mb-2">Quer ajudar mais?</h3>
                            <p class="text-blue-100 text-sm">Cadastre um novo aparelho auditivo no sistema.</p>
                        </div>
                        <a href="doar_aparelho.php" class="block text-center bg-white text-blue-600 w-full py-3 rounded-xl font-black hover:bg-blue-50 transition uppercase tracking-tighter text-sm">
                            Doar Novo Aparelho
                        </a>
                    </div>
                </div>
            <?php endif; ?>

            <!-- ================= VISÃO: CANDIDATO ================= -->
            <?php if ($user_type === 'CANDIDATO'): ?>
                <div class="mb-8">
                    <h2 class="text-2xl font-bold text-gray-900">Aparelhos Disponíveis</h2>
                    <p class="text-gray-500 text-sm">Selecione o modelo compatível com sua perda auditiva para se candidatar.</p>
                </div>

                <?php if (empty($aparelhos)): ?>
                    <div class="bg-white p-8 rounded-2xl border border-gray-200 text-center text-gray-500">
                        Não há aparelhos disponíveis para candidatura no momento.
                    </div>
                <?php else: ?>
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                        <?php foreach ($aparelhos as $a): ?>
                        <?php 
                            $ja_candidatou = false;
                            $status_atual = '';
                            
                            foreach ($candidaturas as $cand) {
                                if (isset($cand['aparelho']) && (int)$cand['aparelho'] === (int)$a['id']) {
                                    $ja_candidatou = true;
                                    $status_atual = $cand['status'] ?? 'AGUARDANDO';
                                    break;
                                }
                            }
                        ?>
                        <div class="bg-white rounded-2xl border border-gray-200 overflow-hidden hover:shadow-xl transition-all group flex flex-col">
                            <div class="h-48 bg-gray-50 flex items-center justify-center p-6 group-hover:scale-105 transition-transform">
                                <img src="<?php echo !empty($a['imagem']) ? $a['imagem'] : 'https://via.placeholder.com/150'; ?>" class="max-h-full object-contain" alt="">
                            </div>
                            <div class="p-6 flex-grow flex flex-col">
                                <div class="mb-4">
                                    <span class="text-[10px] font-bold text-blue-600 uppercase tracking-widest"><?php echo htmlspecialchars($a['marca']); ?></span>
                                    <h3 class="text-lg font-bold text-gray-900 mt-1"><?php echo htmlspecialchars($a['nome']); ?></h3>
                                    <p class="text-xs text-gray-500 mt-2 line-clamp-2"><?php echo htmlspecialchars($a['descricao'] ?? 'Sem descrição fornecida.'); ?></p>
                                </div>
                                
                                <div class="bg-slate-50 rounded-xl p-3 mb-6 space-y-2">
                                    <div class="flex justify-between text-[10px]">
                                        <span class="font-bold text-gray-400 uppercase tracking-tighter">Modelo:</span>
                                        <span class="text-gray-700 font-semibold"><?php echo htmlspecialchars($a['modelo'] ?? 'Padrão'); ?></span>
                                    </div>
                                    <div class="flex justify-between text-[10px]">
                                        <span class="font-bold text-gray-400 uppercase tracking-tighter">Indicação:</span>
                                        <span class="text-orange-600 font-bold"><?php echo htmlspecialchars($a['perda_indicada'] ?? 'Não especificada'); ?></span>
                                    </div>
                                </div>

                                <?php if ($ja_candidatou): ?>
                                    <div class="w-full text-center py-3 rounded-xl font-bold text-sm select-none border tracking-wide uppercase
                                        <?php echo ($status_atual === 'APROVADO') ? 'bg-green-50 border-green-200 text-green-700' : (($status_atual === 'NEGADO') ? 'bg-red-50 border-red-200 text-red-700' : 'bg-amber-50 border-amber-200 text-amber-700'); ?>">
                                        Inscrito: <?php echo htmlspecialchars($status_atual); ?>
                                    </div>
                                <?php else: ?>
                                    <form action="dashboard.php" method="POST" class="mt-auto">
                                        <input type="hidden" name="acao" value="candidatar">
                                        <input type="hidden" name="aparelho_id" value="<?php echo $a['id']; ?>">
                                        <button type="submit" class="w-full bg-slate-900 text-white py-3 rounded-xl font-bold hover:bg-blue-600 transition shadow-lg shadow-gray-200 text-sm">
                                            Candidatar-se
                                        </button>
                                    </form>
                                <?php endif; ?>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>
            <?php endif; ?>

        </main>

        <footer class="bg-white border-t border-gray-200 py-6 text-center text-gray-400 text-xs mt-auto">
            &copy; 2026 AASI. Sistema de Apoio ao Aluno com Deficiência Auditiva.
        </footer>
    </div>
</body>
</html>