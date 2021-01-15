use std::{
    error, fs,
    io::{self, ErrorKind},
    path::Path,
};

type BoxError = Box<dyn error::Error>;

pub fn extract_integer(file_path: &Path) -> Result<u32, BoxError> {
    let str_data = read_file(file_path)?;
    let data = get_number(&str_data)?;
    Ok(data)
}

fn read_file(file_path: &Path) -> Result<String, io::Error> {
    if !file_path.is_file() {
        let not_a_file_error = io::Error::new(
            ErrorKind::InvalidInput,
            format!("Not a file: {}", file_path.display()),
        );
        return Err(not_a_file_error);
    }

    if file_path.extension().unwrap() != "txt" {
        let incorrect_ext_error = io::Error::new(
            ErrorKind::InvalidInput,
            "The file should have txt extension!",
        );
        return Err(incorrect_ext_error);
    }

    let str = fs::read_to_string(file_path)?;
    Ok(str)
}

fn get_number(str: &str) -> Result<u32, std::num::ParseIntError> {
    let result = str.trim().parse::<u32>()?;
    Ok(result)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn read_file_should_return_correct_str() {
        let actual_str = read_file(Path::new("test_data/correct.txt")).unwrap();
        let expected_str = "5\n".to_string();
        assert_eq!(actual_str, expected_str);
    }

    #[test]
    #[should_panic]
    fn read_file_should_panic_if_not_file() {
        read_file(Path::new("test_data/")).unwrap();
    }

    #[test]
    fn read_file_should_return_err_if_not_file() {
        assert!(read_file(Path::new("test_data/")).is_err());
    }

    #[test]
    fn read_file_fail_but_should_pass_if_points_to_txt_file() {
        assert!(read_file(Path::new("test_data/perm_denied.txt")).is_err());
    }

    #[test]
    fn read_file_should_return_error_if_perm_denied() {
        let actual_error_kind = read_file(Path::new("test_data/perm_denied.txt"))
            .unwrap_err()
            .kind();
        let expected_error_kind = ErrorKind::PermissionDenied;
        assert_eq!(actual_error_kind, expected_error_kind);
    }

    #[test]
    fn read_file_should_return_error_if_not_file() {
        let actual_error_kind = read_file(Path::new("test_data/")).unwrap_err().kind();
        let expected_error_kind = ErrorKind::InvalidInput;
        assert_eq!(actual_error_kind, expected_error_kind);
    }

    //not working
    // #[test]
    // fn read_file_should_return_not_a_file_str_error_if_not_file() {
    //     let file_path = Path::new("test_data/");
    //     let actual_inner_error = read_file(file_path).unwrap_err().into_inner().unwrap();
    //     let expected_inner_error = &format!("Not a file: {}", file_path.display());
    //     assert_eq!(actual_inner_error, expected_inner_error);
    // }

    #[test]
    fn read_file_should_return_not_a_file_str_error_if_not_file_alt() {
        let file_path = Path::new("test_data/");
        let actual_inner_error_disp = format!(
            "{}",
            read_file(file_path).unwrap_err().into_inner().unwrap()
        );
        let expected_inner_error_disp = format!("Not a file: {}", file_path.display());
        assert_eq!(actual_inner_error_disp, expected_inner_error_disp);
    }

    #[test]
    #[should_panic(expected = "The file should have txt extension!")]
    fn read_file_should_panic_if_not_txt_file() {
        read_file(Path::new("test_data/incorrect.ttt")).unwrap();
    }

    #[test]
    #[should_panic(expected = "Not a file:")]
    fn read_file_should_panic_expected_if_not_file() {
        read_file(Path::new("test_data/")).unwrap();
    }

    #[test]
    fn get_number_should_return_integer_when_correct_string() {
        let expected_val: u32 = 5;
        let actual_val = get_number(&expected_val.to_string()).unwrap();
        assert_eq!(expected_val, actual_val);
    }

    #[test]
    fn get_number_should_parse_correctly_when_string_with_spaces() {
        let expected_val: u32 = 5;
        let actual_val = get_number(&format!(" {}   ", expected_val)).unwrap();
        assert_eq!(expected_val, actual_val);
    }

    #[test]
    #[should_panic]
    fn get_number_should_panic_when_string_cannot_be_parsed() {
        get_number("j").unwrap();
    }

    #[test]
    fn get_number_returns_error_when_string_cannot_be_parsed() {
        assert!(get_number("j").is_err());
    }

    #[test]
    fn get_number_should_return_error_when_string_if_incorrect_number() {
        match get_number("j") {
            Err(e) if e.to_string() == "invalid digit found in string" => return (),
            Err(_) => panic!("Returned incorrect Err!"),
            Ok(_) => panic!("Returned an Ok variant!"),
        }
    }

    #[test]
    #[should_panic(expected = "invalid digit found in string")]
    fn get_number_returns_error_when_string_is_incorrect() {
        panic!(get_number("j").unwrap_err().to_string());
    }

    // #[test]
    // #[should_panic(expected = "kind: InvalidDigit")]
    // fn get_number_returns_error_when_string_is_incorrect_alt() {
    //     get_number("j").unwrap();
    // }
    
    #[test]
    #[should_panic(expected = "invalid digit found in string")]
    fn get_number_returns_error_when_string_is_incorrect_alt() {
        get_number("j").unwrap();
    }

    // #[test]
    // fn get_number_returns_error_when_string_is_incorrect() {
    //     let actual_error_kind = get_number("j").unwrap_err().kind();
    //     let expected_error_kind = IntErrorKind::InvalidDigit;
    //     assert_eq!(expected_error_kind, actual_error_kind);
    // }

    #[test]
    fn extract_integer_should_return_err_if_incorrect_number() {
        assert!(extract_integer(Path::new("test_data/incorrect_number.txt")).is_err());
    }

    #[test]
    fn extract_integer_should_return_parseinterror_if_incorrect_number() {
        assert!(extract_integer(Path::new("test_data/incorrect_number.txt"))
            .unwrap_err()
            .is::<std::num::ParseIntError>());
    }

    #[test]
    #[should_panic(expected = "Not a file:")]
    fn extract_integer_should_panic_if_not_file() {
        extract_integer(Path::new("test_data/")).unwrap();
    }

    #[test]
    #[should_panic(expected = "The file should have txt extension!")]
    fn extract_integer_should_panic_if_not_txt_file() {
        extract_integer(Path::new("test_data/incorrect.ttt")).unwrap();
    }
}
