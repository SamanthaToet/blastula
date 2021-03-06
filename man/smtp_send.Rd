% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/smtp_send.R
\name{smtp_send}
\alias{smtp_send}
\title{Send an email message through SMTP}
\usage{
smtp_send(email, from, to, subject = NULL, cc = NULL, bcc = NULL,
  creds_file = NULL, sender = NULL, host = NULL, port = NULL,
  user = NULL, password = NULL, use_ssl = TRUE,
  authenticate = TRUE, binary_loc = NULL, echo = FALSE,
  echo_cmd = FALSE, debug = FALSE)
}
\arguments{
\item{email}{The email message object, as created by the \code{compose_email()}
function. The object's class is \code{email_message}}

\item{from}{The email address of the sender. This does not have to be the
same email that is associated with the account actually sending the
message.}

\item{to}{A vector of email addresses serving as primary recipients for the
message. For secondary recipients, use the \code{cc} and \code{bcc} arguments.}

\item{subject}{The subject of the message, which is usually a brief summary
of the topic of the message.}

\item{cc}{A vector of email addresses for sending the message as a carbon
copy. This list of for those who are to receive a copy of a message
addressed primarily to another. The list of recipients in the CC list is
visible to all other recipients of the message.}

\item{bcc}{A vector of email addresses for sending the message as blind
carbon copies. Any email addresses provided here will receive the message
and these email addresses will be concealed from other recipients
(including others on the BCC list).}

\item{creds_file}{An optional path to an email credentials file. This file
must be created by the \code{create_email_creds_file()} function.}

\item{sender}{The sender name.}

\item{host}{The email host.}

\item{port}{The port associated with the email account.}

\item{user}{The username associated with the email account.}

\item{password}{The password associated with the email account.}

\item{use_ssl}{A logical value to indicate whether to use SSL.}

\item{authenticate}{A logical value to indicate whether to use
authentication.}

\item{binary_loc}{An option to supply the location of the \code{mailsend-go}
binary file should it not be on the system path or in the working
directory.}

\item{echo}{An option to print the standard output and error to the screen.}

\item{echo_cmd}{A logical value indicating whether the system command should
be printed to the console during the sending of email.}

\item{debug}{Setting \code{debug} to \code{TRUE} will provide information on all of the
SMTP sending options, and, the email message won't actually be sent. A
tibble of information will be returned. By default, this is set to \code{FALSE}.}
}
\description{
Send an email message to one or more recipients via an SMTP server.
}
\examples{
\dontrun{
# Prepare a test message and send
# the email out with `smtp_send()`
prepare_test_message() \%>\%
  smtp_send(
    from = "sender@mail.com",
    to = "recipient@mail.com",
    subject = "Mail Subject",
    creds_file = ".mail_creds"
  )
}
}
