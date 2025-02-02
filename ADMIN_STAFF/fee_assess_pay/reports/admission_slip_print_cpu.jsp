<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Untitled Document</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <style type="text/css">
      <!--
      .style1 {
      font-size: 12px;
      font-weight: bold;
      }
      -->
    </style>
  </head>
  <style type="text/css">
    <!--
    body {
      font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
      font-size: 11px;
    }

    td {
      font-family: Times New Roman, Times, serif;
      font-size: 11px;
    }

    th {
      font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
      font-size: 11px;
    }
    TABLE.thinborder {
      border-top: solid 1px #000000;
      border-right: solid 1px #000000;
      font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
      font-size: 11px;
    }

    TD.thinborder {
      border-left: solid 1px #000000;
      border-bottom: solid 1px #000000;
      font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
      font-size: 11px;
    }

    -->
  </style>
  <body>
    <%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
    <%
      DBOperation dbOP = null;
      WebInterface WI = new WebInterface(request);

      String strErrMsg = null;
      String strTemp = null;
      String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
      try {
        dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
            "Admin/staff-Fee Assessment & Payments-REPORTS-admission slip print","admission_slip_print_cpu.jsp");
      } catch(Exception exp) {
        exp.printStackTrace();
        //ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

      %>
      <p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
      Error in opening connection</font></p>
    <%
    return;
    }
    Vector vRetResult = null;
      Vector vStudDetail= null;
      String strAdmSlipNumber = null;
      boolean bolIsFinal = false;

      ReportEnrollment reportEnrl= new ReportEnrollment();
      vRetResult = reportEnrl.getStudentLoad(dbOP, request.getParameter("stud_id"),request.getParameter("sy_from"),
          request.getParameter("sy_to"),request.getParameter("offering_sem"));
      if(vRetResult == null)
        strErrMsg = reportEnrl.getErrMsg();
      else// {
        vStudDetail = (Vector)vRetResult.elementAt(0);
      //	//get admission slip number here and as well save the information.
      //	strAdmSlipNumber = reportEnrl.autoGenAdmSlipNum(dbOP,
      //							(String)vStudDetail.elementAt(0),WI.fillTextValue("pmt_schedule"),
      //                           WI.fillTextValue("sy_from"),WI.fillTextValue("offering_sem"),
                            (String)request.getSession(false).getAttribute("userIndex"));
      //	if(strAdmSlipNumber == null)
      //		reportEnrl.getErrMsg();
      //}

      //String strExamSchName = dbOP.mapOneToOther("FA_PMT_SCHEDULE","pmt_sch_index",
      //	WI.fillTextValue("pmt_schedule"),"exam_name",null);
      //if(strExamSchName != null)
      //	strExamSchName = strExamSchName.toUpperCase();

      //String	strCollegeName = null;
      //if(vStudDetail != null && vStudDetail.size() > 0) {
      //	strCollegeName =
      //		new enrollment.CurriculumMaintenance().getCollegeName(dbOP,(String)vStudDetail.elementAt(5));
      //	if(strCollegeName != null)
      //		strCollegeName = strCollegeName.toUpperCase();
      //}

      if(WI.fillTextValue("pmt_schedule").equals("3"))
        bolIsFinal = true;

      int iTotalLoad = 0;
      int iIndex = 1;
      int i = 1;
      int iMaxRows = 11;

      if(strErrMsg != null){dbOP.cleanUP();
      %>
      <table width="50%" border="0">
      <tr>
    <td width="100%"><div align="center"><font size="3"><%=strErrMsg%></font></div></td>
      </tr>
    </table>
    <%return;}
    for(; i < vRetResult.size(); i += 11, iIndex++){%>
    <table width="50%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td height="30"><div align="center"></div></td>
      </tr>
      <tr>
        <td><div align="right">&nbsp;</div></td>
      </tr>
      <tr>
        <td height="25"><div align="center"><strong><%=vStudDetail.elementAt(2)%></strong></div></td>
      </tr>
    </table>
    <table width="50%" border="0" cellspacing="0" cellpadding="0">
      <tr >
        <td width="42%" height="25"><div align="center"></div></td>
      </tr>
      <tr >
        <td height="20" >&nbsp;</td>
      </tr>
    </table>
    <table width="50%" cellpadding="0" cellspacing="0" >
      <%if(bolIsFinal){%>
      <tr>
        <td height="25">&nbsp;&nbsp;&nbsp;Subject</td>
        <td height="25">&nbsp;&nbsp;&nbsp;Instructor's Name</td>
      </tr>
      <%}else{%>
      <tr>
        <td height="25" colspan="2">&nbsp;</td>
      </tr>
      <%}
        for(; i< vRetResult.size(); i += 11, iIndex++){
          //do not show the re-enrolled subjects.
          //strTemp =(String)vRetResult.elementAt(i+1);
          //if (strTemp.length() > 40)	strTemp = strTemp.substring(0,38)+"..";
      %>
      <tr>
        <td height="25" width="50%">&nbsp;&nbsp;&nbsp;<%=vRetResult.elementAt(i)%></td>
        <%if(bolIsFinal)
            strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;");
          else
            strTemp = "&nbsp";%>
        <td width="55%">&nbsp;&nbsp;&nbsp;<%=strTemp%></td>
      </tr>
      <%if(bolIsFinal)
      break;
      }%>
    </table>
    <%if(bolIsFinal){%>
    <DIV style="page-break-before:always" >&nbsp;</DIV>
    <%}
    }%>
    <script src="../../../jscript/common.js"></script>
    <script language="JavaScript">
      //get this from common.js
      this.autoPrint();

      //this.closeWnd = 1;
      this.close();
    </script>
  </body>
</html>
<%
  dbOP.cleanUP();
%>
