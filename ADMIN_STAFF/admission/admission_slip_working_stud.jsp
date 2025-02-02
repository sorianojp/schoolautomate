<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,java.util.Vector,enrollment.CourseRequirement"	%>
<%
        WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Untitled Document</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
    <style type="text/css">
      TABLE.thinborder {
      border-top: solid 1px #000000;
      border-right: solid 1px #000000;
      font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
      font-size: 12px;	
      }

      TABLE.thinborderall {
      border: solid 1px #000000;
      font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
      font-size: 12px;	
      }

      TD.thinborder {
      border-left: solid 1px #000000;
      border-bottom: solid 1px #000000;
      font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
      font-size: 12px;
      }

      TD.thinborderBottom {
      border-bottom: solid 1px #000000;
      font-size: 12px;
      }
    </style>
  </head>
  <script language="javascript" src="../../jscript/common.js"></script>
  <script language="javascript">
    function ReloadPage(){
    document.form_.print_page.value="";
    document.form_.print_pg.value="";
    this.SubmitOnce('form_');
    }
    function OpenSearch(){
    document.form_.print_page.value="";
    document.form_.print_pg.value="";
    var pgLoc = "../../search/srch_stud_temp.jsp?opner_info=form_.temp_id";
    var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
    win.focus();
    }
  </script> 
  
  
  <%
        //authenticate user access level
     int iAccessLevel = -1;
     java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

      if(svhAuth == null)
	      iAccessLevel = -1; // user is logged out.
      else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
    	  iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
      else {
            iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ADMISSION MAINTENANCE-PLACEMENT EXAM"),"0"));
            if(iAccessLevel == 0) {
              iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ADMISSION MAINTENANCE"),"0"));
            }
          }

          if(iAccessLevel == -1)//for fatal error.
          {
            request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
            request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
            response.sendRedirect("../../../commfile/fatal_error.jsp");
            return;
          } else if(iAccessLevel == 0)//NOT AUTHORIZED.
          {
            response.sendRedirect("../../../commfile/unauthorized_page.jsp");
            return;
          }

          DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
              "PURCHASING-PURCHASE ORDER","entrance_admission_slip.jsp");
          OfflineAdmission offlineAdd = new OfflineAdmission();
          CourseRequirement cRequirement = new CourseRequirement();
          Vector vAdmissionReq = null;
          Vector vRetResult = null;
          Vector vCompliedRequirement = null;
          Vector vExamsPassed = null;
		  String strSchCode = (String)request.getSession(false).getAttribute("school_code");
		  
		  
          String strTempID = WI.fillTextValue("temp_id");
          String strErrMsg = null;
          String strTemp = null;
          String strSYFrom = null;
          String strSYTo = null;
          String strSemester = null;
          String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
          String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
          String strPrintBy = WI.fillTextValue("print_by");

          if (strTempID.length() > 0 && !strPrintBy.equals("1")){
            //vRetResult = offlineAdd.createAdmissionSlipReq(dbOP,request,strTempID);
            vRetResult = offlineAdd.createAdmissionSlipReq(dbOP,strTempID);
            if (vRetResult == null)
              strErrMsg = offlineAdd.getErrMsg();
            if(vRetResult != null && vRetResult.size() > 0) {
              strSYFrom = (String)vRetResult.elementAt(0);
              strSYTo = (String)vRetResult.elementAt(1);
              strSemester = (String)vRetResult.elementAt(12);

              vAdmissionReq = cRequirement.getStudentPendingCompliedList(dbOP,(String)vRetResult.elementAt(16),
                  strSYFrom,strSYTo,strSemester,true,true,true);//get both pending and complied list

              if(vAdmissionReq == null && strErrMsg == null)
                strErrMsg = cRequirement.getErrMsg();
              else {
                vCompliedRequirement = (Vector)vAdmissionReq.elementAt(1);
              }
              vExamsPassed = offlineAdd.getExamResults(dbOP,request,strTempID);
            }
          } else if(strPrintBy.equals("1")){
            vRetResult = offlineAdd.getStudentNames(dbOP,request);
            if(vRetResult == null)
              strErrMsg = offlineAdd.getErrMsg();
          }		  
  %>
  <body bgcolor="#D2AE72">
    <form name="form_" method="post" action="./entrance_admission_slip.jsp">
      <table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr bgcolor="#B5AB73"> 
          <td width="91%" height="25" colspan="8"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">:::: 
          WORKING STUDENT ADMISSION SLIP::::</font></strong></div></td>
        </tr>
      </table>
      
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="4"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <%if(!strPrintBy.equals("1")){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Temporary/Stud ID</td>
      <td width="18%"> <input name="temp_id" type="text" class="textbox" value="<%=WI.fillTextValue("temp_id")%>" size="16" maxlength="16"
          onfocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"' >      </td>
      <td width="59%"><a href="javascript:OpenSearch();"><img src="../../images/search.gif" border="0"></a><a href="javascript:ReloadPage();"></a></td>
    </tr>
    <%}%>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="19%">Acad Year / Sem </td>
      <td colspan="2">
<%
  strTemp = WI.fillTextValue("sy_from");
	  if(strTemp.length() ==0) 
	  		strTemp = astrSchYrInfo[0];
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        -

<%
  strTemp = WI.fillTextValue("sy_to");
  if(strTemp.length() ==0) 
	  	strTemp = astrSchYrInfo[1];
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"><select name="semester">
          <option value="0">Summer</option>
<%
	strTemp = WI.fillTextValue("semester");
	if(strTemp.length() ==0)
		strTemp = astrSchYrInfo[2];
	if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
    <%}else{%>
          <option value="1">1st Sem</option>
    <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
    <%}else{%>
          <option value="2">2nd Sem</option>
    <%}if(strTemp.equals("3") && !strSchCode.startsWith("CPU") ){%>
          <option value="3" selected>3rd Sem</option>
    <%}else if(!strSchCode.startsWith("CPU")){%>
          <option value="3">3rd Sem</option>
    <%}%>
        </select></td>
    </tr>
  </table>
      <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
        <tr> 
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td><div align="center"><img src="../../images/save.gif" width="48" height="28"><font size="1">click to save new working student</font> </div></td>
        </tr>
        <tr>
          <td>&nbsp;</td>
        </tr>
      </table>
      <table width="100%" border="0" bgcolor="#B5AB73">
        <tr>
          <td>&nbsp;</td>
        </tr>
      </table>
    </form>

    </body>
</html>
<%
  dbOP.cleanUP();
%>