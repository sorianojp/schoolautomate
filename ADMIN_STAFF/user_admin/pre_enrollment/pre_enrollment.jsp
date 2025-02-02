<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
  <title>Untitled Document</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
  <link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
  <script language="JavaScript" src="../../../jscript/date-picker.js"></script>
  <script language="JavaScript" src="../../../jscript/common.js"></script>
  <script language='JavaScript'>
function ReloadPage(){
	this.SubmitOnce('form_');
}
function PageAction(strAction,strInfoIndex,strDelete){
	if(strAction == 0){
		if(!confirm('Delete '+strDelete+'?'))
		return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	ReloadPage();
}
function Cancel(){
	location = "./pre_enrollment.jsp?sy_from="+
		document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+
		"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value;
}
function PrepareToEdit(strInfoIndex){
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value="1";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}
  </script>
<%@ page language="java" import="utility.*,java.util.Vector"%>
<%
    WebInterface WI = new WebInterface(request);
    DBOperation dbOP = null;
    String strTemp = null;
    String strErrMsg = null;
    
	//authenticate user access level
    int iAccessLevel = -1;
    java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

    if(svhAuth == null)
      iAccessLevel = -1; // user is logged out.
    else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
      iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
    else {
      iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("System Administration-Set Parameters"),"0"));
      if(iAccessLevel == 0) {
        iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("System Administration"),"0"));
      }
    }

    if(iAccessLevel == -1)//for fatal error.
    {
      request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
      request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
      response.sendRedirect("../../../commfile/fatal_error.jsp");
      return;
    } 
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
    {
      response.sendRedirect("../../../commfile/unauthorized_page.jsp");
      return;
    }

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"System Administration-Set Parameters-Pre enrollment","pre_enrollment.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	enrollment.PreEnrollment PE = new enrollment.PreEnrollment();
    Vector vRetResult = null;
    Vector vEditInfo = null;
    String strInfoIndex = WI.fillTextValue("info_index");
    String []astrYrLvl = {"All","1st","2nd","3rd","4th","5th","6th"};
    String []astrDropAdv = {"No","Yes"};
    String []astrSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};
    boolean bolIsEdit = false;

    strTemp = WI.fillTextValue("page_action");
    if(strTemp.length() > 0){
      	if(PE.operateOnPESetting(dbOP,request,Integer.parseInt(strTemp)) != null) {
	  		strErrMsg = "Operation Successful.";
	  		strPreparedToEdit = "0";
		}
	  else	
	  	strErrMsg = PE.getErrMsg();
    }

    vRetResult = PE.operateOnPESetting(dbOP,request,4);
    if(vRetResult == null && strErrMsg == null)
      strErrMsg = PE.getErrMsg();
	if(strPreparedToEdit.equals("1")) {
		vEditInfo = PE.operateOnPESetting(dbOP,request,3);
		if(vEditInfo == null)
			strErrMsg = PE.getErrMsg();
		else	
			bolIsEdit = true;//System.out.println(vEditInfo);
	}

String strSYFrom = null;
String strSYTo   = null;
String strSem    = null;
ReadPropertyFile rProp = new ReadPropertyFile();
strSYFrom = rProp.readProperty(dbOP, "PRE_ENROLLMENT_SYTERM","0");
if(strSYFrom == null || strSYFrom.length() != 6) {
	strErrMsg = "Please set SY-Term information for Pre-enrollment in System setting.";
	strSYFrom = null;
}
else {//2006-0
	strSem = String.valueOf(strSYFrom.charAt(5));
	strSYFrom = strSYFrom.substring(0,4);
	strSYTo   = Integer.toString(Integer.parseInt(strSYFrom) + 1);
}	
	
	
  %>
  <body bgcolor="#D2AE72">
<%if(strSYFrom == null){//return here. %>
<font size="4"><%=strErrMsg%>.<br><a href="../set_param/system_set.jsp#pre-enrol">Click here</a> to go to System setting.</font>
<%dbOP.cleanUP();return;}//%>  
    <form name="form_" method="post" action="pre_enrollment.jsp">
      <table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr bgcolor="#A49A6A">
          <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          </strong></font><font color="#FFFFFF"><strong> PRE-ENROLLMENT SETTINGS
          PAGE ::::</strong></font></div></td>
        </tr>	
        <tr bgcolor="#FFFFFF">
          <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
        </tr>	
      </table>
      
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="17%"><font size="1">SY-Term</font></td>
      <td colspan="2"> 
	  <%if(bolIsEdit)
      		strTemp = (String)vEditInfo.elementAt(1);
        else
        	strTemp = strSYFrom;%> 
		<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
          onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
          onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        - 
        <%if(bolIsEdit)
              strTemp = (String)vEditInfo.elementAt(2);
          else
          	  strTemp = strSYTo;
          %> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
          onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
          onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        - 
        <select name="semester">
          <%if(bolIsEdit)
                strTemp = (String)vEditInfo.elementAt(3);
              else
                strTemp = strSem;
    if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>
		&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>
		&nbsp;&nbsp;
<%strTemp = WI.fillTextValue("view_all");
if(strTemp.length() > 0) 
	strTemp = " checked";
else	
	strTemp = "";
%>		 <input type="checkbox" name="view_all" value="1"<%=strTemp%>> Click to View all </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><font size="1">Res. Duration</font></td>
      <td colspan="2"> 
<%if(bolIsEdit)
	strTemp = (String)vEditInfo.elementAt(4);
  else
    strTemp = WI.fillTextValue("date_fr");%> 
	<input name="date_fr" type="text" class="textbox" size="10" maxlength="10" value="<%=strTemp%>" readonly="yes"> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        To: 
<%if(bolIsEdit)
  strTemp = WI.getStrValue((String)vEditInfo.elementAt(5));
else
  strTemp = WI.fillTextValue("date_to");%> 
  	<input name="date_to" type="text" class="textbox" size="10" maxlength="10" value="<%=strTemp%>" readonly="yes"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><font size="1">Last Date</font></td>
      <td height="25" colspan="3"> 
<%if(bolIsEdit)
  strTemp = WI.getStrValue((String)vEditInfo.elementAt(6));
else
  strTemp = WI.fillTextValue("last_date");%> 
  	<input name="last_date" type="text" class="textbox" size="10" maxlength="10" value="<%=strTemp%>" readonly="yes"> 
        <a href="javascript:show_calendar('form_.last_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        <font color="#0000FF" size="1">- Last date to enroll</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><font size="1"> Course </font></td>
      <td height="25" colspan="3"><font size="1"> 
        <input type="text" name="scroll_course" size="16" style="font-size:9px" class="textbox" 
	  onKeyUp="AutoScrollList('form_.scroll_course','form_.course_index',true);">
        (enter course code to scroll course list)</font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4"> 
<%if(bolIsEdit)
  strTemp = (String)vEditInfo.elementAt(8);
else
  strTemp = WI.fillTextValue("course_index");
//System.out.println(strTemp);  %> 
  		<select name="course_index" style="font-size:11px;background:#DFDBD2;">
			<option value="">&lt;Select Any&gt;</option>
          <%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name as cname",
                " from course_offered where IS_DEL=0 AND IS_VALID=1 order by cname asc",strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="17%" height="25"> <font size="1">Year level </font></td>
      <td height="25" colspan="3"> <select name="year_level">
          <option value="0">ALL</option>
<%if(bolIsEdit)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(9));
else
	strTemp = WI.fillTextValue("year_level");
if(strTemp.equals("1")) {%>
          <option value="1" selected>1st</option>
<%}else{%>
          <option value="1">1st</option>
<%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd</option>
<%}else{%>
          <option value="3">3rd</option>
<%}if(strTemp.equals("4")){%>
          <option value="4" selected>4th</option>
<%}else{%>
          <option value="4">4th</option>
<%}if(strTemp.equals("5")){%>
          <option value="5" selected>5th</option>
<%}else{%>
          <option value="5">5th</option>
<%}if(strTemp.equals("6")){%>
          <option value="6" selected>6th</option>
<%}else{%>
          <option value="6">6th</option>
<%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><font size="1">Invalidate Advising</font><br>
      </td>
      <td colspan="2"> 
<%if(bolIsEdit)
  strTemp = (String)vEditInfo.elementAt(10);
else
  strTemp = WI.fillTextValue("drop_advising");
if(strTemp.equals("1"))
	strTemp = " checked";
else
	strTemp = "";
%>
    <input type="checkbox" name="drop_advising" value="1"<%=strTemp%>>Yes 
	
        <font color="#0000FF" size="1">(If not officially enrolled)</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
<%if(iAccessLevel > 1) {//show if authorized.%>
    <tr> 
      <td height="43">&nbsp;</td>
      <td height="43">&nbsp;</td>
      <td width="48%" height="43" valign="bottom"> 
  		<font size="1"> 
		<%if(strPreparedToEdit.equals("0")){%>
		<a href="javascript:PageAction('1','','');"> 
        <img src="../../../images/save.gif" border="0" name="hide_save"></a> Click 
        to save entries 
		<%}else{%>
		<a href="javascript:PageAction('2','<%=(String)vEditInfo.elementAt(0)%>','');"> 
        <img src="../../../images/edit.gif" border="0" name="hide_save"></a> Click 
        to save entries &nbsp;
		<a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries 
		<%}//for edit.%>
		</font></td>
      <td width="34%" height="43" valign="bottom"></td>
    </tr>
<%}%>	
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
      <%if(vRetResult != null && vRetResult.size() > 3){%>
      <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
        <tr bgcolor="#B9B292"> 
          <td height="23" colspan="8" class="thinborder"><div align="center">&nbsp;</div></td>
        </tr>
        <tr>
          <td width="21%" class="thinborder"><strong><font size="1">SY-TERM</font></strong></td> 
          <td width="21%" height="20" class="thinborder"><div align="center"><strong><font size="1">COURSE</font></strong></div></td>
          <td width="7%" class="thinborder"><div align="center"><strong><font size="1">YEAR LEVEL </font></strong></div></td>
          <td width="30%" class="thinborder"><div align="center"><strong><font size="1">ENROLLMENT DATE </font></strong></div></td>
          <td width="17%" class="thinborder"><div align="center"><strong><font size="1">LAST DATE TO ENROLL </font></strong></div></td>
          <td width="9%" class="thinborder"><div align="center"><strong><font size="1">DROP ADVISING </font></strong></div></td>
          <td width="8%" align="center" class="thinborder"><div align="center"><strong><font size="1">EDIT</font></strong></div></td>
          <td width="8%" align="center" class="thinborder"><div align="center"><strong><font size="1">DELETE</font></strong></div></td>
        </tr>
        <%for(int iLoop = 0;iLoop < vRetResult.size();iLoop += 11){%>
        <tr>
          <td class="thinborder">
		  <%=(String)vRetResult.elementAt(iLoop + 1)%>-<%=((String)vRetResult.elementAt(iLoop + 2)).substring(2)%>
		  (<%=(String)vRetResult.elementAt(iLoop + 3)%>)</td>    
          <td class="thinborder"><%=vRetResult.elementAt(iLoop+7)%></td>
          <td class="thinborder"><%=astrYrLvl[Integer.parseInt((String)vRetResult.elementAt(iLoop+9))]%></td>
          <td class="thinborder"><%=vRetResult.elementAt(iLoop+4)%> - <%=vRetResult.elementAt(iLoop+5)%></td>
          <td class="thinborder"><%=vRetResult.elementAt(iLoop+6)%></td>
          <td class="thinborder"><%=astrDropAdv[Integer.parseInt((String)vRetResult.elementAt(iLoop+10))]%></td>
          <td align="center" class="thinborder"><font size="1"> 
            <%  if(iAccessLevel ==2 || iAccessLevel == 3){%>
            <a href="javascript:PrepareToEdit('<%=vRetResult.elementAt(iLoop)%>');">
            <img src="../../../images/edit.gif" border="0"></a>
            <%}else{%>Not authorized to edit<%}%>
          </font></td>
          <td align="center" class="thinborder"> <font size="1"> 
            <% if(iAccessLevel ==2){%>
            <a href="javascript:PageAction('0','<%=vRetResult.elementAt(iLoop)%>',' this information');">
            <img src="../../../images/delete.gif" border="0"></a>
            <%}else{%>Not authorized to delete<%}%>
          </font></td>
        </tr>
        <%}%>
      </table>
      <%}%>
      <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
        <tr>
          <td height="25">&nbsp;</td>
        </tr>
        <tr bgcolor="#B8CDD1">
          <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
        </tr>
      </table>
      <!-- all hidden fields go here -->
      <input type="hidden" name="page_action">
      <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
      <input type="hidden" name="prepareToEdit" value="<%=strPreparedToEdit%>">
    </form>
  </body>
</html>
<%
  dbOP.cleanUP();
%>