export function sendEmail(to, subject, body) {
  return mail.send({
    to,
    subject,
    body,
  });
}
