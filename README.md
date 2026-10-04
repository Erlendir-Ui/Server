# Server

Personal, provider-agnostic server infrastructure.

## Цель

Личный VPS с воспроизводимым развёртыванием, рассчитанный в том числе на очень небольшие серверы.

Главный принцип — быстро перенести базовую инфраструктуру на новый VPS независимо от провайдера, а тяжёлые или необязательные компоненты подключать отдельно.

## Архитектура

Base system → SSH → Firewall → Swap → Fail2Ban → Lightweight monitoring

Опционально:

- Docker
- Local backup
- Remote/off-site backup
- VPN

VPN остаётся отдельным модулем, чтобы базовую систему можно было переносить между VPS без привязки к конкретному протоколу.

## Быстрый запуск

```bash
git clone https://github.com/Erlendir-Ui/Server.git
cd Server
sudo ./install.sh
```

Перед запуском на удалённом сервере убедитесь, что у вас есть рабочий способ повторного подключения по SSH.

## Базовый профиль для маленьких VPS

Базовая установка намеренно не устанавливает Docker, restic/rclone или тяжёлые системы мониторинга.

Она устанавливает только то, что нужно почти каждому VPS:

- минимальный набор системных пакетов;
- OpenSSH;
- UFW;
- swap до 1 GiB, если swap отсутствует или слишком мал;
- Fail2Ban для SSH;
- лёгкий systemd health-check.

Целевой размер:

- минимум: 512–768 MiB RAM + около 1 GiB swap;
- предпочтительно: 1 GiB RAM + 1 GiB swap;
- диск: желательно 10 GiB, но базовый профиль должен работать и на небольшом диске.

## Опциональные модули

Docker:

```bash
sudo ./modules/docker/install.sh
```

Локальный backup:

```bash
sudo ./modules/backup-local/install.sh
```

Удалённый backup:

```bash
sudo ./modules/backup-remote/install.sh
```

Удалённый backup не включается автоматически: сначала нужно настроить Google Drive/rclone и пароль restic.

## Текущий этап

- [x] Базовый установочный сценарий
- [x] Проверка ОС и root-доступа
- [x] Минимальные системные пакеты
- [x] OpenSSH
- [x] Базовый firewall
- [x] Swap для маленьких VPS
- [x] Fail2Ban
- [x] Lightweight monitoring
- [x] Docker как отдельный модуль
- [x] Local backup как отдельный модуль
- [x] Remote backup как отдельный модуль
- [ ] SSH hardening после подтверждения доступа по ключу
- [ ] VPN

## Структура

```text
Server/
├── README.md
├── install.sh
├── .gitignore
├── scripts/
│   ├── setup-system.sh
│   ├── setup-ssh.sh
│   ├── setup-firewall.sh
│   ├── setup-swap.sh
│   ├── setup-fail2ban.sh
│   └── setup-monitoring.sh
└── modules/
    ├── docker/
    │   └── install.sh
    ├── backup-local/
    │   └── install.sh
    └── backup-remote/
        └── install.sh
```

## Безопасность

1. Секреты не хранятся в Git.
2. По умолчанию открыт только необходимый SSH-порт.
3. VPN-порты открываются отдельным этапом.
4. Password authentication не отключается автоматически до подтверждения доступа по ключу.
5. Docker не является частью базовой установки.
6. Remote backup не активируется до отдельной настройки.
7. Конфигурация должна быть воспроизводимой и пригодной для быстрого переноса на новый VPS.

## Примечание по Docker и firewall

Docker публикует контейнерные порты через собственные сетевые правила. Поэтому перед публикацией VPN-сервисов будет отдельно проверена модель firewall, чтобы случайно не получить открытые наружу порты.
