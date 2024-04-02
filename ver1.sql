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
    UserType ENUM('Student', 'Chairperson', 'Administrator') NOT NULL, -- 유저 타입:(재학생, 동아리 회장, 관리자)
) ENGINE=InnoDB;

-- Clubs Table
CREATE TABLE Clubs (
    ClubID INT AUTO_INCREMENT PRIMARY KEY, -- 동아리 기본키
    Name VARCHAR(255) NOT NULL, -- 동아리명
    ChairpersonID INT NOT NULL, -- 회장 ID
    FOREIGN KEY (ChairpersonID) REFERENCES Users(UserID)
) ENGINE=InnoDB;

-- ClubMembers Table
CREATE TABLE ClubMembers (
    UserID INT NOT NULL, -- 동아리에 등록되어 있는 유저 ID
    ClubID INT NOT NULL, -- 동아리 ID
    PRIMARY KEY (UserID, ClubID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ClubID) REFERENCES Clubs(ClubID)
) ENGINE=InnoDB;

-- SportsSpaces Table
CREATE TABLE SportsSpaces (
    SpaceID INT AUTO_INCREMENT PRIMARY KEY, -- 운동 공간 기본키
    Type ENUM('TennisCourt', 'BasketballCourt', 'SoccerField') NOT NULL, -- 운동 공간 TYPE
    MinimumPeople INT NOT NULL, -- 사용 최소 인원
    CourtNumber INT NULL -- "BasketballCourt"일 경우, 코트 번호를 지정
) ENGINE=InnoDB;

-- Rentals Table
CREATE TABLE Rentals (
    RentalID INT AUTO_INCREMENT PRIMARY KEY, -- 렌탈 기록 기본키
    SpaceID INT NOT NULL, -- 렌탈 공간 기본키
    UserID INT NOT NULL, -- "대여 신청" 유저 기본키
    StartTime DATETIME NOT NULL, -- 대여 시작 날짜/시간
    EndTime DATETIME NOT NULL, -- 대여 종료 날짜/시간
    Status ENUM('Pending', 'Confirmed', 'Rejected') NOT NULL, -- 대여 상태
    MinimumPeopleMet BOOLEAN NOT NULL, -- 최소 대여 조건 충족 여부
    FOREIGN KEY (SpaceID) REFERENCES SportsSpaces(SpaceID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
) ENGINE=InnoDB;

-- RentalParticipants Table
CREATE TABLE RentalParticipants (
    RentalID INT NOT NULL, -- 렌탈 기록 기본 키
    ParticipantID INT NOT NULL, -- "대여 참여" 유저 기본키
    Status ENUM('Invited', 'Accepted') NOT NULL, -- "초대" 받은 상태, "초대 수락"한 상태
    PRIMARY KEY (RentalID, ParticipantID),
    FOREIGN KEY (RentalID) REFERENCES Rentals(RentalID),
    FOREIGN KEY (ParticipantID) REFERENCES Users(UserID)
) ENGINE=InnoDB;

-- Friends Table
CREATE TABLE Friends (
    UserID1 INT NOT NULL, -- 친구 신청 보낸 유저 기본키
    UserID2 INT NOT NULL, -- 친구 신청 받은 유저 기본키
    Status ENUM('Pending', 'Accepted') NOT NULL, -- 대기 상태 혹은 수락
    PRIMARY KEY (UserID1, UserID2),
    FOREIGN KEY (UserID1) REFERENCES Users(UserID),
    FOREIGN KEY (UserID2) REFERENCES Users(UserID)
) ENGINE=InnoDB;

-- ClubTimeSlots Table
CREATE TABLE ClubTimeSlots (
    SlotID INT AUTO_INCREMENT PRIMARY KEY, -- 동아리 전용 시간 기록 기본키
    ClubID INT NOT NULL, -- 동아리 기본키
    DayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL, -- 매주 등록 날짜
    StartTime TIME NOT NULL, -- 시작 시간
    EndTime TIME NOT NULL, -- 종료 시간
    Status ENUM('Allocated', 'OpenForLightning') NOT NULL, -- 최소 인원을 넘겨 "할당 완료" 혹은 최소 인원을 못 넘긴채 일주일도 안남았으면 "추가 모집 가능"
    FOREIGN KEY (ClubID) REFERENCES Clubs(ClubID)
) ENGINE=InnoDB;
