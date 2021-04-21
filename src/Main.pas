unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.AppEvnts;

type
  TfMain = class(TForm)
    btDatasetLoop: TButton;
    btThreads: TButton;
    btStreams: TButton;
    ApplicationEvents1: TApplicationEvents;
    procedure btDatasetLoopClick(Sender: TObject);
    procedure btStreamsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure btThreadsClick(Sender: TObject);

  private

  public

  end;

var
  fMain: TfMain;

implementation

uses
  DatasetLoop, ClienteServidor, Threads, IOUtils;

{$R *.dfm}

procedure TfMain.ApplicationEvents1Exception(Sender: TObject; E: Exception);
var
  logFile: String;
  log: TextFile;
  sb: TStringBuilder;
  sDtaLog, sDtaException: String;
begin
  sDtaLog := FormatDateTime('ddmmyyyy', now);
  sDtaException := FormatDateTime('dd/mm/yyyy hh:nn:ss', now);
  logFile := GetCurrentDir + '\exception_' + sDtaLog + '.log';

  AssignFile(log, logFile);

  if FileExists(logFile) then
    Append(log)
  else
    Rewrite(log);

  WriteLn(log, 'Data/hora......: ' + sDtaException);
  WriteLn(log, 'Exceção........: ' + E.Message);
  WriteLn(log, 'Classe.........: ' + E.ClassName);
  WriteLn(log, 'Onde...........: ' + Screen.ActiveForm.Name);
  WriteLn(log, 'Arquivo........: ' + Sender.UnitName);
  WriteLn(log, 'Controle.......: ' + Screen.ActiveControl.Name);
  WriteLn(log, StringOfChar('-', 70));

  CloseFile(log);

  sb := TStringBuilder.Create;
  try
    sb.AppendLine('Ocorreu um erro na aplicação.')
      .AppendLine('O problema será analisado pelos desenvolvedores.')
      .AppendLine(EmptyStr).AppendLine('Descrição técnica:')
      .AppendLine(E.Message);

    Application.MessageBox(PChar(sb.ToString), 'Erro', MB_OK + MB_ICONERROR);
  finally
    sb.Free;
  end;
end;

procedure TfMain.btDatasetLoopClick(Sender: TObject);
begin
  fDatasetLoop.Show;
end;

procedure TfMain.btStreamsClick(Sender: TObject);
begin
  fClienteServidor.Show;
end;

procedure TfMain.btThreadsClick(Sender: TObject);
begin
  fThreads.Show;
end;

procedure TfMain.FormShow(Sender: TObject);
begin
//  ReportMemoryLeaksOnShutdown := True;
end;

end.
