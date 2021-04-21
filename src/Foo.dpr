program Foo;

uses
  Vcl.Forms,
  Main in 'Main.pas' {fMain},
  DatasetLoop in 'DatasetLoop.pas' {fDatasetLoop},
  ClienteServidor in 'ClienteServidor.pas' {fClienteServidor},
  Threads in 'Threads.pas' {fThreads};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TfDatasetLoop, fDatasetLoop);
  Application.CreateForm(TfClienteServidor, fClienteServidor);
  Application.CreateForm(TfThreads, fThreads);
  Application.Run;
end.
