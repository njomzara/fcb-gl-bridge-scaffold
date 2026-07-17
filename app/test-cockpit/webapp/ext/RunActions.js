sap.ui.define([], function () {
  "use strict";

  async function executeOperation(oModel, sPath) {
    const oContext = oModel.bindContext(sPath);
    await oContext.execute();
    return oContext.getBoundContext();
  }

  return {
    kickoffHappyPath: async function (oEvent) {
      const oModel = oEvent.getSource().getModel();
      await executeOperation(oModel, "/kickoffHappyPath(...)");
      oModel.refresh();
    },

    refreshRun: async function (oEvent) {
      const oModel = oEvent.getSource().getModel();
      const aContexts = this.getSelectedContexts ? this.getSelectedContexts() : [];

      if (aContexts.length === 0) {
        return;
      }

      await executeOperation(oModel, `${aContexts[0].getPath()}/refreshRun(...)`);
      oModel.refresh();
    }
  };
});
