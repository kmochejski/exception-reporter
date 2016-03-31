use Mix.Config

config :exception_reporter,
  notifiers: [{ExceptionReporter.Notifiers.EmailNotifier, :email_notifier}],
  supported_envs: [:prod, :dev]

config :exception_reporter, :email_notifier,
  sender: ~s(sender@example.com),
  recipients: ["recipient@example.com"],
  smtp: [
    relay: "localhost",
    port: 25
  ]
