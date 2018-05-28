USE [master]
GO

:SETVAR DBName "dbar_test"
:SETVAR DataPath "C:\SQL_Data\SSD\Data"
:SETVAR LogPath "C:\SQL_Data\SSD\Log"


CREATE DATABASE [$(DBName)]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'dbareports', FILENAME = N'$(DataPath)\$(DBName).mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ), 
 FILEGROUP [Info]  DEFAULT
( NAME = N'InfoData_01', FILENAME = N'$(DataPath)\$(DBName)_Info_Data_01.ndf' , SIZE = 65536KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ), 
 FILEGROUP [Monitoring] 
( NAME = N'MonitoringData_01', FILENAME = N'$(DataPath)\$(DBName)_MonitoringData01.ndf' , SIZE = 65536KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ),
( NAME = N'MonitoringData_02', FILENAME = N'$(DataPath)\$(DBName)_MonitoringData02.ndf' , SIZE = 65536KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ), 
 FILEGROUP [Staging] 
( NAME = N'StagingData_01', FILENAME = N'$(DataPath)\$(DBName)_StagingData01.ndf' , SIZE = 65536KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ),
( NAME = N'StagingData_02', FILENAME = N'$(DataPath)\$(DBName)_StagingData02.ndf' , SIZE = 65536KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'dbareports_log', FILENAME = N'$(LogPath)\$(DBName)__log.ldf' , SIZE = 139264KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO



