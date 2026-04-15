#uses "classes/GUI/GUIMisc"
#uses "classes/GUI/GUINaviButton"
#uses "classes/GUI/GUINaviButtonCollection"

class GUIBasePanel
{
  private bool _menuOpen = TRUE;
  private shared_ptr<GUINaviButtonCollection> _naviButtons;
  private shape _naviModule;
  private shape _mainModule;
  private string _actualPanel;

  // Constructor simplificado: Solo Navi y Main
  public GUIBasePanel(const shape &naviModule, const shape &mainModule, const string &Screen)
  {
    _naviModule = naviModule;
    _mainModule = mainModule;

    // Nombres internos
    _naviModule.ModuleName = ptms_BuildModuleName("naviModule", Screen);
    _mainModule.ModuleName = ptms_BuildModuleName("mainModule", Screen);

    // Forzamos el color NEGRO en el fondo del módulo de navegación
    // "Siemens_Dark" a veces es azulado, así que aplicamos CSS directo
    _naviModule.backCol = "{21,21,21}";

    // Configuramos el escalado del panel principal
    setScaleStyle(SCALE_FIT_TO_MODULE, _mainModule.ModuleName);

    // Quitamos bordes de ventana de Windows
    titleBar(FALSE);
  }

  public void Initialize()
  {
    // Conectamos los botones del menú lateral
    assignPtr(_naviButtons, invokeMethod(getShape(_naviModule.ModuleName(), rootPanel(_naviModule.ModuleName()), ""), "GetGuiNaviButtonCollection"));
    classConnect(this, ClickedCB, _naviButtons, GUINaviButtonCollection::ClickedEvent);

    // Aplicamos CSS Negro a los botones también
    _naviModule.setStyleSheet("QWidget { background-color: #000000; color: #ffffff; border: none; }");
  }

  private void ClickedCB(const int &mode, const anytype &value, shared_ptr<GUINaviButton> button)
  {
    if (mode == 1) // Modo Navegación
    {
      string newPanelName = "Main_" + createUuid();

      // Si el panel anterior existe, lo quitamos
      if (_actualPanel != "") PanelOffModule(_actualPanel, _mainModule.ModuleName());

      // Cargamos el nuevo panel (el de tu planta)
      RootPanelOnModule(value, newPanelName, _mainModule.ModuleName(), makeDynString());

      _actualPanel = newPanelName;

      // Estética de botones: marcamos el activo
      _naviButtons.SetInactive();
      button.SetActive(TRUE);
    }
    // El modo 2 (abrir/cerrar menú) lo ignoramos si quieres que esté siempre fijo
  }
};
