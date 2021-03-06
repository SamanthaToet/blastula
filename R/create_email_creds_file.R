#' Create a file with email access credentials
#'
#' Create a file with access credentials for the purpose of automatically
#' emailing notification messages.
#' @param user The username for the email account.
#' @param password The password associated with the email account.
#' @param provider An optional provider email provider with which an STMP
#'   account is available. Options currently include `gmail`, `outlook`, and
#'   `office365`. If nothing is provided then values for `host`, `port`,
#'   `sender`, `use_ssl`, `use_tls`, and `authenticate` are expected.
#' @param host The `host` name.
#' @param port The port number.
#' @param sender The sender name.
#' @param use_ssl An option as to whether to use SSL; supply a `TRUE` or `FALSE`
#'   value (`TRUE` is the default value).
#' @param use_tls A logical value to indicate whether to use TLS; supply a
#'   `TRUE` or `FALSE` value (`FALSE` is the default value).
#' @param authenticate An option as to whether to authenticate; supply a `TRUE`
#'   or `FALSE` value (`TRUE` is the default value).
#' @param creds_file_name An option to specify a name for the credentials file.
#'   If no name is provided, one will be automatically generated. The
#'   autogenerated file will be invisible and have its name constructed in the
#'   following way: `.bls_<host_name>`.
#' @examples
#' \dontrun{
#' # Create a credentials file to facilitate
#' # the sending of email messages
#' create_email_creds_file(
#'   user = "user_name@gmail.com",
#'   password = "************",
#'   provider = "gmail"
#'   )
#' }
#' @importFrom stringr str_replace_all
#' @importFrom dplyr pull filter
#' @export
create_email_creds_file <- function(user,
                                    password,
                                    provider = NULL,
                                    host = NULL,
                                    port = NULL,
                                    sender = NULL,
                                    use_ssl = TRUE,
                                    use_tls = FALSE,
                                    authenticate = TRUE,
                                    creds_file_name = NULL) {

  # Add bindings to global variables
  short_name <- server <- NULL

  # Ensure that `use_ssl` is either TRUE or FALSE
  if (!(use_ssl %in% c(TRUE, FALSE))) {
    stop("The value supplied to `use_ssl` must be TRUE or FALSE.")
  }

  # Ensure that `use_tls` is either TRUE or FALSE
  if (!(use_tls %in% c(TRUE, FALSE))) {
    stop("The value supplied to `use_tls` must be TRUE or FALSE.")
  }

  # Ensure that `authenticate` is either TRUE or FALSE
  if (!(authenticate %in% c(TRUE, FALSE))) {
    stop("The value supplied to `authenticate` must be TRUE or FALSE.")
  }

  # If a `provider` name is given, extract values for `host`,
  # `port`, `use_ssl`, `use_tls`, and `authenticate`
  if (!is.null(provider) &&
      provider %in% (smtp_settings() %>% dplyr::pull(short_name))) {

    # Extract the record for the SMTP provider
    settings_record <-
      smtp_settings() %>%
      dplyr::filter(short_name == provider)

    # Extract settings for the provider
    host <- settings_record %>% dplyr::pull(server)
    port <- settings_record %>% dplyr::pull(port)
    use_ssl <- settings_record %>% dplyr::pull(use_ssl)
    use_tls <- settings_record %>% dplyr::pull(use_tls)
    authenticate <- settings_record %>% dplyr::pull(authenticate)
  }

  # Collect all credential values into a
  # named vector
  credentials <- c(
    sender = as.character(sender),
    host = as.character(host),
    port = as.character(port),
    user = as.character(user),
    password = as.character(password),
    use_ssl = as.character(use_ssl),
    use_tls = as.character(use_tls),
    authenticate = as.character(authenticate))

  if (is.null(creds_file_name)) {

    # Construct a file name
    file <-
      paste0(
        ".bls_",
        stringr::str_replace_all(
          string = host,
          pattern = "\\.",
          replacement = "_"))

  } else {
    file <- as.character(creds_file_name)
  }

  # Save the credential values as an RDS file
  saveRDS(credentials, file = file)
}


#' Store SMTP credentials in the system's key-value store
#'
#' Set SMTP access credentials using the **keyring** package.
#' @param key_name An option to specify an identifier for the stored credentials
#'   in the keyring. If no name is provided, then the provider name will be used
#'   if available.
#' @param provider An optional email provider name with which an STMP account is
#'   available. Options currently include `gmail`, `outlook`, and `office365`.
#'   If a `provider` is not given, then values for `host`, `port`, and `use_ssl`
#'   will be used.
#' @param user The username for the email account.
#' @param sender The sender name.
#' @param host The `host` name.
#' @param port The port number.
#' @param use_ssl An option as to whether to use SSL; supply a `TRUE` or `FALSE`
#'   value (`TRUE` is the default value).
#' @examples
#' \dontrun{
#' # Store SMTP crendentials using the system's
#' # secure key-value store
#' set_stmp_credentials(
#'   provider = "gmail",
#'   user = "user_name@gmail.com",
#'   )
#' }
#' @import keyring
#' @import glue
#' @importFrom dplyr pull filter
set_smtp_credentials <- function(key_name = NULL,
                                 provider = NULL,
                                 user = NULL,
                                 sender = NULL,
                                 host = NULL,
                                 port = NULL,
                                 use_ssl = TRUE) {

  if (!keyring::has_keyring_support()) {
    stop("To store SMTP via *keyring*, the system needs to have",
         "*keyring* support", call. = FALSE)
  }

  # Ensure that `use_ssl` is either TRUE or FALSE
  if (!(use_ssl %in% c(TRUE, FALSE))) {
    stop("The value supplied to `use_ssl` must be TRUE or FALSE.")
  }

  if (!is.null(provider) &&
      provider %in% (smtp_settings() %>% dplyr::pull(short_name))) {

    # Extract the record for the SMTP provider
    settings_record <-
      smtp_settings() %>%
      dplyr::filter(short_name == provider)

    # Extract settings for the provider
    host <- settings_record$server
    port <- settings_record$port
    use_ssl <- settings_record$use_ssl
  }

  # If the `user` or `sender` aren't provided, use
  # empty strings
  if (is.null(user)) user <- ""
  if (is.null(sender)) sender <- ""

  # Use the provider name if it's given as the
  # `key_name` (if that's not given)
  if (is.null(key_name) && !is.null(provider)) {
    key_name <- provider
  } else if (is.null(key_name)) {
    key_name <- ""
  }

  # Create the `service_name` with contains some useful
  # identifying informtion and metadata within the string
  service_name <-
    glue::glue("blastula-v1({key_name})--{sender}--{host}--{port}--{use_ssl}")

  # Get the password interactively
    password <- getPass::getPass("Enter the SMTP server password: ")

  # Set the key in the system's default keyring
  keyring::key_set_with_value(
    service = service_name,
    user = user,
    password = password
  )
}


#' Utility function for obtaining keyring entries related to blastula creds
#'
#' @import keyring
#' @importFrom dplyr as_tibble filter mutate
#' @importFrom tidyr separate
#' @noRd
bls_keyring_creds_table <- function(version = 1) {

  creds_tbl <-
    keyring::key_list() %>%
    dplyr::as_tibble() %>%
    dplyr::filter(grepl(paste0("blastula-v", version), service))

  if (nrow(creds_tbl) == 0) {

    empty_creds_tbl <-
      dplyr::tibble(
        key_name = NA_character_,
        sender = NA_character_,
        host = NA_character_,
        port = NA_integer_,
        use_ssl = NA,
        username = NA_character_
      )[-1, ]

    return(empty_creds_tbl)

  } else {

    creds_tbl <-
      creds_tbl %>%
      tidyr::separate(
        col = service,
        sep = "--",
        into = c("key_name", "sender", "host", "port", "use_ssl")
      ) %>%
      dplyr::mutate(key_name = gsub(
        paste0("blastula-v", version, "\\("), "", key_name)
      ) %>%
      dplyr::mutate(key_name = gsub(
        "\\)", "", key_name)
      ) %>%
      dplyr::mutate(port = as.integer(port)) %>%
      dplyr::mutate(use_ssl = as.logical(use_ssl))
  }

  creds_tbl
}


#' Retrieve metadata and authentication values from keyring data
#'
#' @import keyring
#' @importFrom dplyr filter
#' @importFrom tidyr separate
#' @noRd
get_smtp_credentials <- function(key_name = NULL,
                                 version = 1) {

  creds_tbl <- bls_keyring_creds_table()

  creds_tbl <-
    creds_tbl %>%
    dplyr::filter(key_name == key_name)

  if (nrow(creds_tbl) == 0) {

    stop("There are no credentials for the given `key_name`.",
         call. = FALSE)
  }

  creds_tbl <- creds_tbl[1, ]

  key_name <- creds_tbl$key_name
  sender <- creds_tbl$sender
  host <- creds_tbl$host
  port <- creds_tbl$port
  use_ssl <- creds_tbl$use_ssl
  username <- creds_tbl$username

  service_name <-
    glue::glue("blastula-v{version}({key_name})--{sender}--{host}--{port}--{use_ssl}")

  password <- keyring::key_get(service = service_name)

  list(
    sender = sender,
    host = host,
    port = port,
    username = username,
    password = password,
    use_ssl = use_ssl
  )
}
