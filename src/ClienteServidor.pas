unit ClienteServidor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB,
  System.Threading;

type
  TServidor = class
  private
    FPath: String;
  public
    constructor Create;
    //Tipo do parâmetro não pode ser alterado
    function SalvarArquivos(AData: OleVariant): Boolean;
    procedure ExcluirArquivos();
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btEnviarParaleloClick(Sender: TObject);
  private
    FPath: String;
    FServidor: TServidor;

    function InitDataset: TClientDataset;
  public
  end;

var
  fClienteServidor: TfClienteServidor;

const
  QTD_ARQUIVOS_ENVIAR = 100;

implementation

uses
  IOUtils;

{$R *.dfm}

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin

  try
    ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
    for i := 0 to QTD_ARQUIVOS_ENVIAR - 1 do
    begin
      cds := InitDataset;
      try
        cds.Append;
        cds.Fields[0].Value := i + 1;
        TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
        cds.Post;
        FServidor.SalvarArquivos(cds.Data);
        ProgressBar.Position := i;
        Application.ProcessMessages;
      finally
        FreeAndNil(cds);
      end;
{$REGION Simulação de erro, não alterar}
      if i = (QTD_ARQUIVOS_ENVIAR / 2) then
        FServidor.SalvarArquivos(NULL);
{$ENDREGION}
    end;
    ProgressBar.Position := 0;
  except
    on E: Exception do
    begin
      FServidor.ExcluirArquivos;
      raise Exception.Create('Erro na cópia dos arquivos, a operação foi desfeita');
    end;
  end;
end;

procedure TfClienteServidor.btEnviarParaleloClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
  InicioProcessamento: TDateTime;
begin
  InicioProcessamento := Now;
  ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;

  cds := InitDataset;

  TParallel.For(0, QTD_ARQUIVOS_ENVIAR,
              procedure (i: integer)
              begin
                TThread.Queue(TThread.CurrentThread,
                  procedure
                  begin
                    try
                      cds.Append;
                      cds.Fields[0].Value := i + 1;
                      TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
                      cds.Post;
                      FServidor.SalvarArquivos(cds.Data);
                      ProgressBar.Position := i;
                      Application.ProcessMessages;
                    finally
                      //FreeAndNil(cds);
                    end;
                  end)
              end);

  ProgressBar.Position := 0;
  ShowMessage('Tempo de processamento:' +
    FormatDateTime('hh:nn:ss:zzz', Now - InicioProcessamento));
end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
  for i := 0 to QTD_ARQUIVOS_ENVIAR - 1 do
  begin
    cds := InitDataset;
    try
      cds.Append;
      cds.Fields[0].Value := i + 1;
      TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
      cds.Post;
      FServidor.SalvarArquivos(cds.Data);
      ProgressBar.Position := i;
      Application.ProcessMessages;
    finally
      FreeAndNil(cds);
    end;
  end;
  ProgressBar.Position := 0;
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
//  FPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf';
//  FServidor := TServidor.Create;

//  FPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf';

  FServidor := TServidor.Create;

  FPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf';


//  FPath := ExtractFilePath(ParamStr(0)) + 'Servidor\pdf.pdf';

end;

procedure TfClienteServidor.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FServidor);
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.CreateDataSet;
end;

{ TServidor }

constructor TServidor.Create;
begin
  FPath := ExtractFilePath(ParamStr(0)) + 'Servidor\';
end;

function TServidor.SalvarArquivos(AData: OleVariant): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
begin
  Result := False;
  cds := TClientDataset.Create(nil);
  cds.Data := AData;
  try
    try
{$REGION Simulação de erro, não alterar}
      if cds.RecordCount = 0 then
        Exit;
{$ENDREGION}
      cds.First;

      while not cds.Eof do
      begin
        FileName := FPath + cds.RecNo.ToString + '.pdf';
        if TFile.Exists(FileName) then
          TFile.Delete(FileName);

        TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);
        cds.Next;
      end;

      Result := True;
    except
      raise;
    end;
  finally
    FreeAndNil(cds);
  end;
end;

procedure TServidor.ExcluirArquivos;
var
  sr: TSearchRec;
begin
//  if (FindFirst(Self.FPath + '\*.pdf', faAnyFile, sr) = 0) then
//  begin
//    repeat
//      TFile.Delete(Self.FPath + '\' + sr.Name);
//    until FindNext(sr) <> 0;
//    FindClose(sr);
//  end;

  if (FindFirst(Self.FPath + '\*.pdf', faAnyFile, sr) = 0) then
  begin
    repeat
      TFile.Delete(Self.FPath + '\' + sr.Name);
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;


end;

end.
