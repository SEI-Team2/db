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
    UserType ENUM('Student', 'Chairperson', 'Administrator') NOT NULL -- 유저 타입:(재학생, 동아리 회장, 관리자)
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
    ApplicationTimeLimit INT NOT NULL, -- 신청 확정 최소 기한, 최소 일주일 전의 Minimium People이 모여야 된다면 -> 7
    CourtNumber INT NULL -- "BasketballCourt"일 경우, 코트 번호를 지정
) ENGINE=InnoDB;

-- Rentals Table
CREATE TABLE Rentals (
    RentalID INT AUTO_INCREMENT PRIMARY KEY, -- 렌탈 기록 기본키
    SpaceID INT NOT NULL, -- 렌탈 공간 기본키
    UserID INT NOT NULL, -- "대여 신청" 유저 기본키
    StartTime DATETIME NOT NULL, -- 대여 시작 날짜/시간
    EndTime DATETIME NOT NULL, -- 대여 종료 날짜/시간
    CreateTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, -- 대여 신청 생성 시간
    Status ENUM('Pending', 'Confirmed', 'Rejected') NOT NULL, -- 아직 최소 대여 조건 충족 못했을 경우(Pending), 최소 대여 조건 충족했을 경우 (Accepted), 반려당한 경우 (Rejected)
    MinimumPeopleMet BOOLEAN NOT NULL, -- 최소 대여 조건 충족 여부
    FOREIGN KEY (SpaceID) REFERENCES SportsSpaces(SpaceID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
) ENGINE=InnoDB;

-- RentalParticipants Table
CREATE TABLE RentalParticipants (
    RentalID INT NOT NULL, -- 렌탈 기록 기본 키
    ParticipantID INT NOT NULL, -- "대여 참여" 유저 기본키
    Status ENUM('Invited', 'Accepted') NOT NULL, -- "초대" 받은 상태, "초대 수락"한 상태(번개 모임을 익명의 유저가 신청한 경우, 바로 Accepted)
    PRIMARY KEY (RentalID, ParticipantID),
    FOREIGN KEY (RentalID) REFERENCES Rentals(RentalID),
    FOREIGN KEY (ParticipantID) REFERENCES Users(UserID)
) ENGINE=InnoDB;

-- ClubTimeSlots Table
CREATE TABLE ClubTimeSlots (
    SlotID INT AUTO_INCREMENT PRIMARY KEY, -- 동아리 전용 시간 기록 기본키
    SpaceID INT NOT NULL, -- 렌탈 공간 기본키
    ClubID INT NOT NULL, -- 동아리 기본키
    StartTime DATETIME NOT NULL, -- 대여 시작 날짜/시간
    EndTime DATETIME NOT NULL, -- 대여 종료 날짜/시간
    Status ENUM('Pending','Confirmed', 'OpenForLightning','Rejected') NOT NULL, -- 기한이 일주일 넘게 남았고 + 아직 최소 대여 조건 충족 못했을 경우(Pending), 최소 대여 조건 충족했을 경우 (Accepted), 일주일도 안남았는데 최소 대여 조건 충족 못했을 경우 (OpenForLightning), 반려당한 경우 (Rejected)
    MinimumPeopleMet BOOLEAN NOT NULL, -- 최소 대여 조건 충족 여부
    FOREIGN KEY (ClubID) REFERENCES Clubs(ClubID),
    FOREIGN KEY (SpaceID) REFERENCES SportsSpaces(SpaceID)
) ENGINE=InnoDB;

-- ClubTimeSlotParticipants to track participation in ClubTimeSlots
CREATE TABLE ClubTimeSlotParticipants (
    SlotID INT NOT NULL, -- 동아리 전용 시간 기록 기본키
    UserID INT NOT NULL, -- 유저 기본키
    PRIMARY KEY (SlotID, UserID),
    FOREIGN KEY (SlotID) REFERENCES ClubTimeSlots(SlotID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
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

-- 알림의 경우
-- 4.1. "Student"."Chairman"의 경우, 본인이 만든 모임이 확정되었을 때, (Rentals 의 Status가 Pending -> Confirmed)
-- 		      본인이 만든 모임이 반려되었을 때, (Rentals 의 Status가 Confirmed -> Rejected)
-- 		      본인이 참여한 모임이 확정되었을 때, (RentalParticipants의 Rentals의 Status가 Pending -> Confirmed)
-- 		      본인이 참여한 모임이 반려되었을 때, (RentalParticipants의 Rentals의 Status가 Confirmed -> Rejected)
-- 		      본인이 보낸 친구 신청이 수락되었을 때, (Friends의 Status가 Pending->Accepted면 User ID1에게)
-- 		      본인이 어느 동아리에 소속되었을 때, (ClubMembers의 UserID에게)
-- 4.2 "Administrator" 의 경우, 모임이 확정되었을 때, (Rentals의 Status가 Pending -> Confirmed, ClubTimeSlots의 Status가 Confirmed이 된 경우)
