USE [master]
GO
/****** Object:  Database [StomatoloskaOrdinacija]    Script Date: 8.3.2021. 7:39:43 ******/
CREATE DATABASE [StomatoloskaOrdinacija]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'StomatoloskaOrdinacija', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\StomatoloskaOrdinacija.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'StomatoloskaOrdinacija_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\StomatoloskaOrdinacija_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [StomatoloskaOrdinacija].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET ARITHABORT OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET  DISABLE_BROKER 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET  MULTI_USER 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET DB_CHAINING OFF 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET QUERY_STORE = OFF
GO
USE [StomatoloskaOrdinacija]
GO
/****** Object:  User [tin]    Script Date: 8.3.2021. 7:39:43 ******/
CREATE USER [tin] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_securityadmin] ADD MEMBER [tin]
GO
/****** Object:  UserDefinedFunction [dbo].[CheckAvailability]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[CheckAvailability]
(
	-- Add the parameters for the function here
	@Id INT,
	@Time DATETIME,
	@EndTime DATETIME
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result INT;

	SET @Result = (SELECT COUNT(*) FROM dbo.Appointment WHERE 
	(Time < @EndTime) AND (EndTime > @Time) AND Active = 1 AND Id <> @Id)

	RETURN @Result
END
GO
/****** Object:  UserDefinedFunction [dbo].[CheckWorkHours]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[CheckWorkHours]
(
	-- Add the parameters for the function here
	@Time DATETIME,
	@EndTime DATETIME
)
RETURNS BIT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Start DATETIME, @End DATETIME, @Result BIT;

	SET @Start = (SELECT TOP(1) [StartTime] FROM dbo.WorkHours) 
	SET @End = (SELECT TOP(1) [EndTime] FROM dbo.WorkHours) 
	SET @Result = CAST(0 AS BIT);

	IF CAST(@Time AS TIME) >= CAST(@Start AS TIME) AND CAST(@Time AS TIME) <= CAST(@End AS TIME) AND
		CAST(@EndTime AS TIME) >= CAST(@Start AS TIME) AND CAST(@EndTime AS TIME) <= CAST(@End AS TIME)
		SET @Result = CAST(1 AS BIT);

	RETURN @Result
END
GO
/****** Object:  UserDefinedFunction [dbo].[SetGapDateFn]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[SetGapDateFn]
(
	-- Add the parameters for the function here
	@Gap DATETIME,
	@Time DATETIME
)
RETURNS DATETIME
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result DATETIME;

	-- Add the T-SQL statements to compute the return value here
	SET @Result = DATETIMEFROMPARTS(YEAR(@Gap), MONTH(@Gap), DAY(@Gap), DATEPART(HOUR, @Time),DATEPART(MI, @Time),DATEPART(S, @Time),0)

	RETURN @Result

END
GO
/****** Object:  UserDefinedFunction [dbo].[UnusedByOperationsFn]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[UnusedByOperationsFn]
(
  @StartDate DATE,
  @EndDate DATE
)
RETURNS @Result TABLE
(
  [Name] NVARCHAR(200),
  [Price] DECIMAL (19,2),
  [Count] INT
)
AS
BEGIN

	INSERT INTO @Result 
	SELECT O.Name, SUM(O.Price) AS Sum, COUNT(*) AS Count
		FROM dbo.Appointment AS A 
		LEFT OUTER JOIN dbo.Operation AS O ON O.Id = A.OperationId
	WHERE A.Active = 1 AND A.Completed = 0 AND Time BETWEEN @StartDate AND @EndDate
	GROUP BY A.OperationId, O.Name

--EXAMPLE: 	SELECT * FROM dbo.[UnusedByOperationsFn](DATEADD(dd,-1,CONVERT(DATETIME,CONVERT( DATE, GETDATE()))),DATEADD(dd,3,CONVERT(DATETIME,CONVERT( DATE, GETDATE()))) ) 

  RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[UnusedTimeFn]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[UnusedTimeFn]
(
)
RETURNS @Result TABLE
(
  [GapStart] DATETIME,
  [GapEnd] DATETIME,
  [Diff] BIGINT
)
AS
BEGIN

	DECLARE @tempTbl TABLE (GapStart DATETIME, GapEnd DATETIME);
	DECLARE @Start DATETIME, @End DATETIME;

	SET @Start = (SELECT TOP(1) [StartTime] FROM dbo.WorkHours) 
	SET @End = (SELECT TOP(1) [EndTime] FROM dbo.WorkHours) 

	INSERT INTO @tempTbl
		SELECT
			e1.EndTime, 
			MIN(e2.Time) AS NextEventTime
		FROM
		dbo.Appointment AS e1
			JOIN dbo.Appointment AS e2 ON  (e1.EndTime <= e2.Time)
		GROUP BY e1.EndTime
		HAVING (DATEDIFF(s, e1.EndTime, MIN(e2.Time)) > 0)
		ORDER BY e1.EndTime		

	DECLARE @CursorTestID INT = 1;
	DECLARE @RunningTotal BIGINT = 0;
	DECLARE @RowCnt BIGINT = 0;
	
	DECLARE @GapStart DATETIME, @GapEnd DATETIME, @Date DATETIME;

	DECLARE @finalTbl TABLE (GapStart DATETIME, GapEnd DATETIME);

	SELECT @RowCnt = COUNT(0) FROM @tempTbl;
 
	WHILE @CursorTestID <= @RowCnt
	BEGIN
    
		SELECT @GapStart = GapStart, @GapEnd = GapEnd
			FROM 
				(
				SELECT 
				ROW_NUMBER() OVER (ORDER BY GapStart) AS RowNum
				, *
				FROM @tempTbl
				) t2
			WHERE RowNum = @CursorTestID 

		IF @GapStart < @GapEnd AND DATEPART(DAY,@GapStart) = DATEPART(DAY,@GapEnd)
			INSERT INTO @finalTbl VALUES (@GapStart, @GapEnd)
	
		ELSE IF CAST(@GapStart AS TIME) >  CAST(@GapEnd AS TIME) AND  @GapStart < @GapEnd
			BEGIN			
				IF @GapStart <> [dbo].[SetGapDateFn](@GapStart, @End) AND DATEPART(DW, @GapStart) <= 6
					INSERT INTO @finalTbl VALUES (@GapStart, [dbo].[SetGapDateFn](@GapStart, @End))  

				IF [dbo].[SetGapDateFn](DATEADD(day, 1, @GapStart), @Start) <> @GapEnd AND DATEPART(DW, @GapStart) <= 6
				BEGIN
					SET @Date = [dbo].[SetGapDateFn](DATEADD(day, 1, @GapStart), @Start)

					IF DATEPART(DAY, @Date) = 6
						INSERT INTO @finalTbl VALUES ([dbo].[SetGapDateFn](DATEADD(day, 3, @GapStart), @Start), @GapEnd)
					else
						INSERT INTO @finalTbl VALUES ([dbo].[SetGapDateFn](DATEADD(day, 1, @GapStart), @Start), @GapEnd)
				END
			END

		SET @CursorTestID = @CursorTestID + 1 
 
	END

	INSERT INTO @Result SELECT *, DATEDIFF(s, GapStart, GapEnd)/60 AS Diff FROM @finalTbl 


--EXAMPLE: 	SELECT * FROM dbo.[UnusedTimeFn](DATEADD(dd,-1,CONVERT(DATETIME,CONVERT( DATE, GETDATE()))),DATEADD(dd,3,CONVERT(DATETIME,CONVERT( DATE, GETDATE()))) ) 

  RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[UsedByDatesFn]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[UsedByDatesFn]
(
  @StartDate DATE,
  @EndDate DATE
)
RETURNS @Result TABLE
(
  [Date] DATE,
  [Price] DECIMAL (19,2),
  [Count] INT
)
AS
BEGIN
  DECLARE @tempTbl TABLE ( Price DECIMAL(19,2), Count INT);
  DECLARE @CurrentDate DATE;
  DECLARE @Count INT;
  DECLARE @Sum DECIMAL (19,2);

  SET @CurrentDate = @StartDate;

  WHILE @CurrentDate <= @EndDate
  BEGIN	   

  	SET @Count = 0;
	SET @Sum = 0;

	INSERT INTO @tempTbl SELECT SUM(O.Price), COUNT(*)
	FROM dbo.Appointment A 
	LEFT OUTER JOIN dbo.Operation AS O ON O.Id = A.OperationId 
	WHERE     (A.Active = 1 AND A.Completed = 1 AND
	(A.Time >= DATEADD(d, 0, CONVERT(DATETIME, CONVERT( DATE, @CurrentDate))) AND 
	A.Time <= DATEADD(d, 1, CONVERT(DATETIME, CONVERT( DATE, @CurrentDate)))))


	SET @Count = (SELECT Count FROM @tempTbl);
	SET @Sum = ISNULL((SELECT SUM(Price) FROM @tempTbl), 0);
  
    INSERT INTO @Result VALUES (@CurrentDate, @Sum, @Count);

    SELECT @CurrentDate = DATEADD(d, 1, @CurrentDate);
	   	
	DELETE FROM @tempTbl 
  END

  --EXAMPLE: 	SELECT * FROM dbo.UsedByDatesFn(DATEADD(dd,-1,CONVERT(DATETIME,CONVERT( DATE, GETDATE()))),DATEADD(dd,3,CONVERT(DATETIME,CONVERT( DATE, GETDATE()))) ) 

  RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[UsedByOperationsFn]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[UsedByOperationsFn]
(
  @StartDate DATE,
  @EndDate DATE
)
RETURNS @Result TABLE
(
  [Name] NVARCHAR(200),
  [Price] DECIMAL (19,2),
  [Count] INT
)
AS
BEGIN

	INSERT INTO @Result 
	SELECT O.Name, SUM(O.Price) AS Sum, COUNT(*) AS Count
		FROM dbo.Appointment AS A 
		LEFT OUTER JOIN dbo.Operation AS O ON O.Id = A.OperationId
	WHERE A.Active = 1 AND A.Completed = 1 AND Time BETWEEN @StartDate AND @EndDate
	GROUP BY A.OperationId, O.Name

--EXAMPLE: 	SELECT * FROM dbo.[UsedByOperationsFn](DATEADD(dd,-1,CONVERT(DATETIME,CONVERT( DATE, GETDATE()))),DATEADD(dd,3,CONVERT(DATETIME,CONVERT( DATE, GETDATE()))) ) 

  RETURN
END
GO
/****** Object:  Table [dbo].[Operation]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Operation](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Active] [bit] NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[Price] [decimal](10, 2) NOT NULL,
	[DurationId] [int] NOT NULL,
 CONSTRAINT [PK_Zahvat] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Duration]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Duration](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Active] [bit] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[DurationInMinutes] [int] NOT NULL,
 CONSTRAINT [PK_Trajanje] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Patient]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Patient](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Active] [bit] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[DateOfBirth] [date] NOT NULL,
	[Phone] [nvarchar](20) NOT NULL,
	[Address] [nvarchar](150) NULL,
 CONSTRAINT [PK_Pacijent] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Appointment]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Appointment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Active] [bit] NOT NULL,
	[Time] [datetime] NOT NULL,
	[Completed] [bit] NOT NULL,
	[PatientId] [int] NOT NULL,
	[OperationId] [int] NOT NULL,
	[EndTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Narudzba] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vAppointment]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vAppointment]
AS
SELECT   A.Id, A.Completed, A.Time, A.PatientId, P.FirstName, P.LastName, A.OperationId, O.Code, O.Name, O.DurationId, D.Name AS DurationName, D.DurationInMinutes, A.EndTime
FROM         dbo.Appointment AS A LEFT OUTER JOIN
                         dbo.Patient AS P ON P.Id = A.PatientId LEFT OUTER JOIN
                         dbo.Operation AS O ON O.Id = A.OperationId LEFT OUTER JOIN
                         dbo.Duration AS D ON D.Id = O.DurationId
WHERE     (A.Active = 1)
GO
/****** Object:  View [dbo].[vOperation]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vOperation]
AS
SELECT   O.Id, O.Code, O.Name, O.Price, O.DurationId, D.Name AS DurationName, D.DurationInMinutes
FROM         dbo.Operation AS O LEFT OUTER JOIN
                         dbo.Duration AS D ON O.DurationId = D.Id
WHERE     (O.Active = 1)
GO
/****** Object:  Table [dbo].[WorkHours]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkHours](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NOT NULL,
 CONSTRAINT [PK_RadnoVrijeme] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Appointment] ON 

INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (16, 1, CAST(N'2021-03-03T13:00:00.000' AS DateTime), 0, 6, 2, CAST(N'2021-03-03T14:00:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (17, 1, CAST(N'2021-03-10T12:00:00.000' AS DateTime), 0, 6, 1, CAST(N'2021-03-10T12:30:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (18, 1, CAST(N'2021-03-11T12:00:00.000' AS DateTime), 0, 6, 1, CAST(N'2021-03-11T12:30:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (19, 1, CAST(N'2021-03-11T09:00:00.000' AS DateTime), 1, 6, 2, CAST(N'2021-03-11T10:00:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (20, 1, CAST(N'2021-03-04T12:00:00.000' AS DateTime), 0, 7, 7, CAST(N'2021-03-04T13:00:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (21, 1, CAST(N'2021-03-04T08:00:00.000' AS DateTime), 0, 6, 1, CAST(N'2021-03-04T08:30:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (22, 1, CAST(N'2021-03-08T12:00:00.000' AS DateTime), 1, 7, 4, CAST(N'2021-03-08T14:00:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (23, 1, CAST(N'2021-03-09T12:00:00.000' AS DateTime), 0, 6, 4, CAST(N'2021-03-09T14:00:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (30, 1, CAST(N'2021-03-05T12:00:00.000' AS DateTime), 1, 7, 4, CAST(N'2021-03-05T14:00:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (32, 1, CAST(N'2021-03-05T09:00:00.000' AS DateTime), 0, 6, 1, CAST(N'2021-03-05T09:30:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (33, 1, CAST(N'2021-03-05T08:00:00.000' AS DateTime), 0, 6, 1, CAST(N'2021-03-05T08:30:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (34, 1, CAST(N'2021-03-05T10:00:00.000' AS DateTime), 0, 6, 1, CAST(N'2021-03-05T10:30:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (35, 1, CAST(N'2021-03-02T12:00:00.000' AS DateTime), 1, 6, 4, CAST(N'2021-03-02T14:00:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (37, 1, CAST(N'2021-03-01T13:30:00.000' AS DateTime), 0, 7, 4, CAST(N'2021-03-01T15:30:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (39, 1, CAST(N'2021-03-04T08:30:00.000' AS DateTime), 0, 6, 1, CAST(N'2021-03-04T09:00:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (40, 1, CAST(N'2021-03-04T13:30:00.000' AS DateTime), 0, 6, 4, CAST(N'2021-03-04T15:30:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (41, 1, CAST(N'2021-03-01T12:00:00.000' AS DateTime), 0, 6, 2, CAST(N'2021-03-01T13:00:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (42, 1, CAST(N'2021-03-01T13:00:00.000' AS DateTime), 0, 6, 1, CAST(N'2021-03-01T13:30:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (43, 1, CAST(N'2021-03-01T08:00:00.000' AS DateTime), 0, 6, 4, CAST(N'2021-03-01T10:00:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (44, 0, CAST(N'2021-02-24T12:00:00.000' AS DateTime), 0, 6, 1, CAST(N'2021-02-24T12:30:00.000' AS DateTime))
INSERT [dbo].[Appointment] ([Id], [Active], [Time], [Completed], [PatientId], [OperationId], [EndTime]) VALUES (45, 1, CAST(N'2021-03-11T10:00:00.000' AS DateTime), 0, 6, 1, CAST(N'2021-03-12T10:30:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[Appointment] OFF
SET IDENTITY_INSERT [dbo].[Duration] ON 

INSERT [dbo].[Duration] ([Id], [Active], [Name], [DurationInMinutes]) VALUES (1, 1, N'30 minuta', 30)
INSERT [dbo].[Duration] ([Id], [Active], [Name], [DurationInMinutes]) VALUES (2, 1, N'1 sat', 60)
INSERT [dbo].[Duration] ([Id], [Active], [Name], [DurationInMinutes]) VALUES (4, 1, N'2 sata', 120)
SET IDENTITY_INSERT [dbo].[Duration] OFF
SET IDENTITY_INSERT [dbo].[Operation] ON 

INSERT [dbo].[Operation] ([Id], [Active], [Code], [Name], [Price], [DurationId]) VALUES (1, 1, N'IP', N'Inicijalni pregled', CAST(53.00 AS Decimal(10, 2)), 1)
INSERT [dbo].[Operation] ([Id], [Active], [Code], [Name], [Price], [DurationId]) VALUES (2, 1, N'PL', N'Plombiranje', CAST(105.00 AS Decimal(10, 2)), 2)
INSERT [dbo].[Operation] ([Id], [Active], [Code], [Name], [Price], [DurationId]) VALUES (4, 1, N'APR', N'Postavljanje aparatića', CAST(7005.00 AS Decimal(10, 2)), 4)
INSERT [dbo].[Operation] ([Id], [Active], [Code], [Name], [Price], [DurationId]) VALUES (7, 1, N'VU', N'Vađenje umnjaka', CAST(552.50 AS Decimal(10, 2)), 2)
INSERT [dbo].[Operation] ([Id], [Active], [Code], [Name], [Price], [DurationId]) VALUES (8, 0, N'test', N'delete', CAST(10.00 AS Decimal(10, 2)), 1)
INSERT [dbo].[Operation] ([Id], [Active], [Code], [Name], [Price], [DurationId]) VALUES (9, 0, N'test2', N'asd', CAST(10.00 AS Decimal(10, 2)), 1)
INSERT [dbo].[Operation] ([Id], [Active], [Code], [Name], [Price], [DurationId]) VALUES (10, 0, N'fg', N'fgh', CAST(10.00 AS Decimal(10, 2)), 1)
INSERT [dbo].[Operation] ([Id], [Active], [Code], [Name], [Price], [DurationId]) VALUES (11, 0, N'12', N'2', CAST(2.00 AS Decimal(10, 2)), 1)
INSERT [dbo].[Operation] ([Id], [Active], [Code], [Name], [Price], [DurationId]) VALUES (12, 0, N't', N't', CAST(2.00 AS Decimal(10, 2)), 1)
INSERT [dbo].[Operation] ([Id], [Active], [Code], [Name], [Price], [DurationId]) VALUES (13, 0, N'si', N'ka', CAST(130.00 AS Decimal(10, 2)), 2)
INSERT [dbo].[Operation] ([Id], [Active], [Code], [Name], [Price], [DurationId]) VALUES (14, 0, N'te', N'1', CAST(10.00 AS Decimal(10, 2)), 1)
INSERT [dbo].[Operation] ([Id], [Active], [Code], [Name], [Price], [DurationId]) VALUES (15, 0, N'gh', N'hj', CAST(2.00 AS Decimal(10, 2)), 4)
SET IDENTITY_INSERT [dbo].[Operation] OFF
SET IDENTITY_INSERT [dbo].[Patient] ON 

INSERT [dbo].[Patient] ([Id], [Active], [FirstName], [LastName], [DateOfBirth], [Phone], [Address]) VALUES (1, 0, N'Mirko', N'Mirkic', CAST(N'2000-12-12' AS Date), N'0991234234', N'Zagrebačka 1')
INSERT [dbo].[Patient] ([Id], [Active], [FirstName], [LastName], [DateOfBirth], [Phone], [Address]) VALUES (6, 1, N'Pero', N'Peric', CAST(N'2000-02-02' AS Date), N'098 6598 546', N'Zagrebačka 12')
INSERT [dbo].[Patient] ([Id], [Active], [FirstName], [LastName], [DateOfBirth], [Phone], [Address]) VALUES (7, 1, N'Mirko', N'Mirkić', CAST(N'1995-12-31' AS Date), N'095 9658 654', N'Varaždinska 123')
SET IDENTITY_INSERT [dbo].[Patient] OFF
SET IDENTITY_INSERT [dbo].[WorkHours] ON 

INSERT [dbo].[WorkHours] ([Id], [StartTime], [EndTime]) VALUES (1, CAST(N'2021-02-07T08:00:00.000' AS DateTime), CAST(N'2021-02-07T15:30:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[WorkHours] OFF
/****** Object:  Index [IX_Trajanje]    Script Date: 8.3.2021. 7:39:44 ******/
CREATE NONCLUSTERED INDEX [IX_Trajanje] ON [dbo].[Duration]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Appointment] ADD  CONSTRAINT [DF_Appointment_Active]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [dbo].[Duration] ADD  CONSTRAINT [DF_Trajanje_Active]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [dbo].[Operation] ADD  CONSTRAINT [DF_Zahvat_Active]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [dbo].[Patient] ADD  CONSTRAINT [DF_Patient_Active]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD  CONSTRAINT [FK_Narudzba_Pacijent] FOREIGN KEY([PatientId])
REFERENCES [dbo].[Patient] ([Id])
GO
ALTER TABLE [dbo].[Appointment] CHECK CONSTRAINT [FK_Narudzba_Pacijent]
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD  CONSTRAINT [FK_Narudzba_Zahvat] FOREIGN KEY([OperationId])
REFERENCES [dbo].[Operation] ([Id])
GO
ALTER TABLE [dbo].[Appointment] CHECK CONSTRAINT [FK_Narudzba_Zahvat]
GO
ALTER TABLE [dbo].[Operation]  WITH CHECK ADD  CONSTRAINT [FK_Zahvat_Zahvat] FOREIGN KEY([DurationId])
REFERENCES [dbo].[Duration] ([Id])
GO
ALTER TABLE [dbo].[Operation] CHECK CONSTRAINT [FK_Zahvat_Zahvat]
GO
/****** Object:  StoredProcedure [dbo].[CheckAvailabilitySP]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CheckAvailabilitySP]
@Id INT,
@Start DATETIME,
	@End DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [dbo].[CheckAvailability](@Id, @Start, @End)
END
GO
/****** Object:  StoredProcedure [dbo].[CheckWorkHoursSP]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CheckWorkHoursSP]
	-- Add the parameters for the stored procedure here
	@Start DATETIME,
	@End DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [dbo].[CheckWorkHours](@Start, @End)
END
GO
/****** Object:  StoredProcedure [dbo].[UnusedByOperationsSP]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UnusedByOperationsSP]
	-- Add the parameters for the stored procedure here
@Start DATETIME,
@End DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.	
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *  FROM dbo.[UnusedByOperationsFn](@Start,@End)
END
GO
/****** Object:  StoredProcedure [dbo].[UnusedTimeSP]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UnusedTimeSP]
		-- Add the parameters for the stored procedure here
@Start DATETIME,
@End DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 	* FROM dbo.[UnusedTimeFn]()
	WHERE GapStart > @Start
	AND GapEnd < @End
END
GO
/****** Object:  StoredProcedure [dbo].[UsedByDatesSP]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UsedByDatesSP]
	-- Add the parameters for the stored procedure here
	@Start DATETIME,
	@End DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		SELECT * FROM dbo.UsedByDatesFn(@Start,  @End) 
END
GO
/****** Object:  StoredProcedure [dbo].[UsedByOperationsSP]    Script Date: 8.3.2021. 7:39:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UsedByOperationsSP]
	-- Add the parameters for the stored procedure here
@Start DATETIME,
@End DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM dbo.UsedByOperationsFn(@Start,@End)
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "A"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "P"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "O"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 136
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "D"
            Begin Extent = 
               Top = 6
               Left = 662
               Bottom = 136
               Right = 850
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1920
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vAppointment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vAppointment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "O"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "D"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 434
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vOperation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vOperation'
GO
USE [master]
GO
ALTER DATABASE [StomatoloskaOrdinacija] SET  READ_WRITE 
GO
