-- Database Creation
CREATE DATABASE IF NOT EXISTS CampusSportsRental;
USE CampusSportsRental;

-- Users Table
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY, -- 유저 기본키
    StudentNumber VARCHAR(255) UNIQUE NULL, -- 학번
    Name VARCHAR(255) NOT NULL, -- 유저 명
    ContactInformation VARCHAR(255) NOT NULL, -- 전화번호
    Email VARCHAR(255) UNIQUE NOT NULL, -- 학교 이메일
    Verified BOOLEAN DEFAULT FALSE, -- 이메일 인증 여부
    UserType ENUM('Student', 'Administrator') NOT NULL DEFAULT 'Student',-- 유저 타입:(재학생, 관리자)
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL -- 유저 생성 시간
) ENGINE=InnoDB;

-- Friends Table
CREATE TABLE Friends (
    UserID1 INT NOT NULL, -- 친구 신청 보낸 유저 기본키
    UserID2 INT NOT NULL, -- 친구 신청 받은 유저 기본키
    Status ENUM('Pending', 'Accepted', 'Rejected')DEFAULT 'Pending' NOT NULL, -- 대기 상태 혹은 수락
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 친구 신청 생성 시간
    PRIMARY KEY (UserID1, UserID2),
    FOREIGN KEY (UserID1) REFERENCES Users(UserID) ON DELETE CASCADE, 
    FOREIGN KEY (UserID2) REFERENCES Users(UserID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- SportsSpaces Table
CREATE TABLE SportsSpaces (
    SpaceID INT AUTO_INCREMENT PRIMARY KEY, -- 운동 공간 기본키
    Name VARCHAR(255) NOT NULL, -- 운동 공간 이름
    Location VARCHAR(255), -- 운동 공간 위치
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, -- 운동 공간 생성 시간
    Type ENUM('TennisCourt', 'BasketballCourt', 'SoccerField') NOT NULL, -- 운동 공간 TYPE
    MinimumPeople INT NOT NULL, -- 사용 최소 인원
    MaxPeople INT NOT NULL, -- 사용 최대 인원
    ApplicationTimeLimit INT NOT NULL, -- 신청 확정 최소 기한, 하루 전의 Minimium People이 모여야 된다면 -> 1
    CourtNumber INT NULL -- "BasketballCourt"일 경우, 코트 번호를 지정
) ENGINE=InnoDB;

-- Rentals Table
CREATE TABLE Rentals (
    RentalID INT AUTO_INCREMENT PRIMARY KEY, -- 렌탈 기록 기본키
    SpaceID INT NOT NULL, -- 렌탈 공간 기본키
    UserID INT NOT NULL, -- "대여 신청" 유저 기본키
    ClubID INT NULL, -- "대여 신청" 동아리 기본키
    Type ENUM('Individual', 'ClubRegular', 'Restriction') NOT NULL, -- 대여 타입: 개인, 동아리 정기, 제한
    StartTime DATETIME NOT NULL, -- 대여 시작 날짜/시간
    EndTime DATETIME NOT NULL, -- 대여 종료 날짜/시간
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,  -- 대여 신청 생성 시간
    Status ENUM('Pending', 'Confirmed', 'Failed','Restricted') DEFAULT 'Pending', -- 대여 상태: 대기, 확정, 실패, 제한
    MaxParticipants INT NOT NULL,  -- 최대 참여 인원
    CurrentParticipants INT DEFAULT 0, -- 현재 참여 인원
    UNIQUE(SpaceID, StartTime, EndTime, Status), -- 중복 방지
    FOREIGN KEY (SpaceID) REFERENCES SportsSpaces(SpaceID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (ClubID) REFERENCES Clubs(ClubID) ON DELETE CASCADE

) ENGINE=InnoDB;

-- RentalParticipants Table
CREATE TABLE RentalParticipants (
    RentalID INT NOT NULL, -- 렌탈 기록 기본 키
    ParticipantID INT NOT NULL, -- "대여 참여" 유저 기본키
    PRIMARY KEY (RentalID, ParticipantID),
    FOREIGN KEY (RentalID) REFERENCES Rentals(RentalID),
    FOREIGN KEY (ParticipantID) REFERENCES Users(UserID)
) ENGINE=InnoDB;

CREATE TABLE LightningRentals(
    LightningRentalID INT AUTO_INCREMENT PRIMARY KEY, -- 번개모임 대여 기록 기본키
    RentalID INT NOT NULL, -- 렌탈 기록 기본키
    FOREIGN KEY (RentalID) REFERENCES Rentals(RentalID) ON DELETE CASCADE
) ENGINE=InnoDB;


-- Clubs Table
CREATE TABLE Clubs (
    ClubID INT AUTO_INCREMENT PRIMARY KEY, -- 동아리 기본키
    Name VARCHAR(255) NOT NULL, -- 동아리명
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL -- 동아리 생성 시간
) ENGINE=InnoDB;

-- ClubMembers Table
CREATE TABLE ClubMembers (
    UserID INT NOT NULL, -- 동아리에 등록되어 있는 유저 ID
    ClubID INT NOT NULL, -- 동아리 ID
    Role ENUM('member', 'manager') DEFAULT 'member', -- 동아리 내에서 역할
    PRIMARY KEY (UserID, ClubID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ClubID) REFERENCES Clubs(ClubID)
) ENGINE=InnoDB;

-- 동아리 정기 대여 시간 테이블
CREATE TABLE ClubRegularRentals (
    ClubRegularRentalID INT AUTO_INCREMENT PRIMARY KEY, -- 동아리 정기 대여 기록 기본키
    ClubID INT NOT NULL, -- 동아리 기본키
    SpaceID INT NOT NULL, -- 대여 공간 기본키
    DayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL, -- 대여 요일
    StartTime TIME NOT NULL, -- 대여 시작 시간
    EndTime TIME NOT NULL, -- 대여 종료 시간
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 대여 신청 생성 시간
    UNIQUE(SpaceID, DayOfWeek, StartTime, EndTime), -- 중복 방지
    FOREIGN KEY (ClubID) REFERENCES Clubs(ClubID) ON DELETE CASCADE, 
    FOREIGN KEY (SpaceID) REFERENCES SportsSpaces(SpaceID) ON DELETE CASCADE
) ENGINE=InnoDB;


-- Notifications table to track notification for all users
CREATE TABLE Notifications (
    NotificationID INT AUTO_INCREMENT PRIMARY KEY, -- 알림 ID
    UserID INT NOT NULL, -- 알림에 해당하는 유저
    Message TEXT NOT NULL, -- 알림 내용
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP, -- 현재 시간
    ReadStatus ENUM('Unread', 'Read') DEFAULT 'Unread' NOT NULL, -- 읽었는지 안읽었는지 내용
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
) ENGINE=InnoDB;

-- 블랙리스트 테이블
CREATE TABLE Blacklist (
    BlacklistID INT AUTO_INCREMENT PRIMARY KEY, -- 블랙리스트 ID
    UserID INT NOT NULL, -- 블랙리스트에 추가된 유저
    Reason TEXT NOT NULL, -- 블랙리스트 추가 이유
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 블랙리스트 추가 시간
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE -- 유저 삭제시 블랙리스트 삭제
) ENGINE=InnoDB;

-- 알림의 경우
-- 4.1. "Student"."Chairman"의 경우, 본인이 만든 모임이 확정되었을 때, (Rentals 의 Status가 Pending -> Confirmed)
-- 		      본인이 만든 모임이 반려되었을 때, (Rentals 의 Status가 Confirmed -> Rejected)
-- 		      본인이 참여한 모임이 확정되었을 때, (RentalParticipants의 Rentals의 Status가 Pending -> Confirmed)
-- 		      본인이 참여한 모임이 반려되었을 때, (RentalParticipants의 Rentals의 Status가 Confirmed -> Rejected)
-- 		      본인이 보낸 친구 신청이 수락되었을 때, (Friends의 Status가 Pending->Accepted면 User ID1에게)
-- 		      본인이 어느 동아리에 소속되었을 때, (ClubMembers의 UserID에게)
-- 4.2 "Administrator" 의 경우, 모임이 확정되었을 때, (Rentals의 Status가 Pending -> Confirmed, ClubTimeSlots의 Status가 Confirmed이 된 경우)

-- 트리거: 동아리 정기 대여 시간이 설정될 때 기존 일정을 'Failed'로 업데이트
DELIMITER //
CREATE TRIGGER before_club_regular_rental_insert
BEFORE INSERT ON ClubRegularRentals
FOR EACH ROW
BEGIN
    UPDATE Rentals
    SET Status = 'Failed'
    WHERE SpaceID = NEW.SpaceID
      AND ((StartTime BETWEEN CONCAT(CURDATE(), ' ', NEW.StartTime) AND CONCAT(CURDATE(), ' ', NEW.EndTime))
        OR (EndTime BETWEEN CONCAT(CURDATE(), ' ', NEW.StartTime) AND CONCAT(CURDATE(), ' ', NEW.EndTime))
        OR (StartTime <= CONCAT(CURDATE(), ' ', NEW.StartTime) AND EndTime >= CONCAT(CURDATE(), ' ', NEW.EndTime)))
      AND Status IN ('Pending', 'Confirmed', 'Restricted');
END //
DELIMITER ;

-- 트리거: 'ClubRegular' 일정에 참여하는 유저가 동아리 회원인지 확인
DELIMITER //
CREATE TRIGGER check_club_regular_participation
BEFORE INSERT ON RentalParticipants
FOR EACH ROW
BEGIN
    DECLARE club_id INT;
    DECLARE rental_type ENUM('Individual', 'ClubRegular', 'Restriction');
    
    -- 해당 Rental의 ClubID와 Type을 조회
    SELECT ClubID, Type INTO club_id, rental_type
    FROM Rentals
    WHERE RentalID = NEW.RentalID;
    
    -- 'ClubRegular' 타입인 경우 참여 유저가 동아리 회원인지 확인
    IF rental_type = 'ClubRegular' THEN
        IF NOT EXISTS (
            SELECT 1
            FROM ClubMembers
            WHERE UserID = NEW.ParticipantID
              AND ClubID = club_id
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Participant must be a member of the club for ClubRegular rentals';
        END IF;
    END IF;
END //
DELIMITER ;