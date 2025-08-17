<%@ Page Language="C#" AutoEventWireup="true" CodeFile="err.aspx.cs" Inherits="error" %>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QL7 Bank - Ошибка</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', sans-serif;
        }
        .error-animation {
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.7; }
        }
    </style>
</head>
<body class="bg-gray-50">
    <div class="min-h-screen flex flex-col items-center justify-center p-4">
        <div id="errorContainer" class="w-full max-w-md bg-white rounded-xl shadow-lg overflow-hidden transition-all duration-300">
            <!-- Заголовок ошибки -->
            <div class="bg-red-600 px-6 py-4">
                <div class="flex items-center justify-between">
                    <h2 id="errorTitle" class="text-xl font-semibold text-white">Ошибка</h2>
                    <svg id="errorIcon" class="h-8 w-8 text-white error-animation" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
            </div>
            
            <!-- Содержимое ошибки -->
            <div class="px-6 py-4">
                <div class="mb-4">
                    <p id="errorMessage" class="text-gray-700 mb-2">Произошла непредвиденная ошибка.</p>
                    <p id="errorDetails" class="text-sm text-gray-500"></p>
                </div>
                
                <div id="errorActions" class="mt-6 flex flex-col space-y-3">
                    <button id="btnRetry" onclick="retryOperation()" 
                            class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                        Повторить попытку
                    </button>
                    <button onclick="goToDashboard()" 
                            class="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors">
                        Вернуться в личный кабинет
                    </button>
                    <button onclick="contactSupport()" 
                            class="px-4 py-2 text-blue-600 hover:text-blue-800 transition-colors text-sm">
                        Связаться со службой поддержки
                    </button>
                </div>
                
                <!-- Дополнительная информация (показывается только для определенных ошибок) -->
                <div id="additionalInfo" class="mt-6 hidden">
                    <div class="bg-yellow-50 border-l-4 border-yellow-400 p-4">
                        <div class="flex">
                            <div class="flex-shrink-0">
                                <svg class="h-5 w-5 text-yellow-400" viewBox="0 0 20 20" fill="currentColor">
                                    <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                                </svg>
                            </div>
                            <div class="ml-3">
                                <p id="errorSolution" class="text-sm text-yellow-700"></p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Технические детали (разворачиваются по клику) -->
                <div class="mt-6">
                    <button id="btnToggleDetails" onclick="toggleDetails()" 
                            class="flex items-center text-sm text-gray-500 hover:text-gray-700">
                        <span>Технические детали</span>
                        <svg id="detailsIcon" class="ml-1 h-4 w-4 transform transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                        </svg>
                    </button>
                    <div id="technicalDetails" class="hidden mt-2 p-3 bg-gray-100 rounded-md text-xs text-gray-600 overflow-x-auto">
                        <pre id="errorStackTrace"></pre>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Логотип банка -->
        <div class="mt-8">
            <img src="/images/ql7-logo.svg" alt="QL7 Bank" class="h-10">
        </div>
    </div>

    <script>
        // Получаем параметры ошибки из URL
        const urlParams = new URLSearchParams(window.location.search);
        const errorType = urlParams.get('type');
        const errorCode = urlParams.get('code');
        
        // Обновляем интерфейс в зависимости от типа ошибки
        function updateUI() {
            const errorTitle = document.getElementById('errorTitle');
            const errorMessage = document.getElementById('errorMessage');
            const errorIcon = document.getElementById('errorIcon');
            const additionalInfo = document.getElementById('additionalInfo');
            
            switch(errorType) {
                case 'auth':
                    errorTitle.textContent = 'Ошибка авторизации';
                    errorMessage.textContent = 'Не удалось авторизоваться в системе. Проверьте свои учетные данные.';
                    document.getElementById('errorSolution').textContent = 'Проверьте правильность введенного логина и пароля. Если проблема сохраняется, воспользуйтесь восстановлением пароля.';
                    additionalInfo.classList.remove('hidden');
                    break;
                    
                case 'payment':
                    errorTitle.textContent = 'Ошибка платежа';
                    errorMessage.textContent = 'Не удалось выполнить платеж.';
                    document.getElementById('errorSolution').textContent = 'Проверьте баланс счета и реквизиты получателя. Если сумма превышает лимит, разбейте платеж на несколько частей.';
                    additionalInfo.classList.remove('hidden');
                    break;
                    
                case 'api':
                    errorTitle.textContent = 'Ошибка API';
                    errorMessage.textContent = 'Произошла ошибка при обращении к API банка.';
                    document.getElementById('errorSolution').textContent = 'Попробуйте повторить операцию позже. Если ошибка сохраняется, обратитесь в поддержку.';
                    additionalInfo.classList.remove('hidden');
                    break;
                    
                default:
                    errorTitle.textContent = 'Неизвестная ошибка';
                    errorMessage.textContent = 'Произошла непредвиденная ошибка.';
            }
            
            if (errorCode) {
                document.getElementById('errorDetails').textContent = `Код ошибки: ${errorCode}`;
            }
        }
        
        function toggleDetails() {
            const details = document.getElementById('technicalDetails');
            const icon = document.getElementById('detailsIcon');
            
            if (details.classList.contains('hidden')) {
                details.classList.remove('hidden');
                icon.classList.add('rotate-180');
            } else {
                details.classList.add('hidden');
                icon.classList.remove('rotate-180');
            }
        }
        
        function retryOperation() {
            // Здесь должна быть логика повторения операции
            // Для примера просто обновляем страницу
            window.location.reload();
        }
        
        function goToDashboard() {
            window.location.href = '/ЛичныйКабинет.aspx';
        }
        
        function contactSupport() {
            window.location.href = '/Поддержка.aspx?error=' + encodeURIComponent(errorType || 'unknown');
        }
        
        // Инициализация при загрузке
        document.addEventListener('DOMContentLoaded', function() {
            updateUI();
            
            // Анимация появления
            const container = document.getElementById('errorContainer');
            container.classList.add('opacity-0', 'scale-95');
            setTimeout(() => {
                container.classList.remove('opacity-0', 'scale-95');
                container.classList.add('opacity-100', 'scale-100');
            }, 50);
        });
    </script>
</body>
</html>