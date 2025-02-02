<%@ page language="java" import="utility.*,enrollment.GradeSystemTransferee,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style>

.branch{
	display: none;
	margin-left: 0px;
}	
	
</style>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function showBranch(branch){
	if (document.getElementById(branch) == null) 
		return;

	var objBranch = document.getElementById(branch).style;
	
	if(document.form_.is_internship.checked) 
		objBranch.display="block";
	else
		objBranch.display="none";
}

function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.page_action.value = "";
	document.form_.firstRun.value = "0";
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce('form_');
}


function UpdateSchoolList()
{
	//pop up here.
	var pgLoc = "../sub_creditation/schools_accredited.jsp?parent_wnd=form_";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CloseWindow(){
	document.form_.close_wnd_called.value = "1";
	window.opener.document.studdata_entry.submit();
	window.opener.focus();
	self.close();
}
function ReloadParentWnd() {

	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.studdata_entry.submit();
		window.opener.focus();
	}
}

</script>

<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">

<%

	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	Vector vTemp = null;
	int iCtr = 0;
	String strDegreeType = null;
	String[] strCurInfo = null;
	String strFirstRun = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-TRANSFEREE INFO MAINTENANCE","transferee_alter_entry.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","TRANSFEREE INFO MAINTENANCE",request.getRemoteAddr(),
														"transferee_alter_entry.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

GradeSystemTransferee GSTransferee = new GradeSystemTransferee();
if (WI.fillTextValue("student_type").equals("Transferee"))
	vTemp = GSTransferee.getTransfereeStudInfo(dbOP, request.getParameter("stud_id"));
else
	vTemp = GSTransferee.getSecondCourseStudInfo(dbOP, request.getParameter("stud_id"));
	
if(vTemp == null)
	strErrMsg = GSTransferee.getErrMsg();
else//
{
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","course_index",(String)vTemp.elementAt(4),"DEGREE_TYPE",null);
	if(strDegreeType == null)
		strErrMsg = "Error in getting course degree type.";
	else if(WI.fillTextValue("page_action").length() > 0)
	{
	  if(GSTransferee.operateOnModTransData(dbOP,request,Integer.parseInt(request.getParameter("page_action"))) != null)
	  	strErrMsg = "Operation successful.";
	  else
	  	strErrMsg = GSTransferee.getErrMsg();
	}
}

	strFirstRun = WI.getStrValue(request.getParameter("firstRun"),"1");
	if (strFirstRun.equals("1")){
	vRetResult = GSTransferee.operateOnModTransData(dbOP, request, 0);
	if (vRetResult == null && strErrMsg == null)
			strErrMsg = GSTransferee.getErrMsg();
	else
		strFirstRun = "0";
	}
	
	if(WI.fillTextValue("equiv_code").length() > 0 && 
				!WI.fillTextValue("equiv_code").equals("0")){ 
	// I have to get the curriculum detail infromation.
	
		strCurInfo = GSTransferee.getCurIndex(dbOP,request.getParameter("equiv_code"),
							  (String)vTemp.elementAt(4),(String)vTemp.elementAt(5),
                              (String)vTemp.elementAt(6),(String)vTemp.elementAt(7),strDegreeType);
							  
		if(strCurInfo == null && strErrMsg == null)
			strErrMsg = GSTransferee.getErrMsg();
	}
%>
<form action="./transferee_alter_entry.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          <%=WI.fillTextValue("student_type").toUpperCase()%> INFORMATION MANAGEMENT :::: </strong></font></div></td>
    </tr>
    <tr>
    <td colspan="4" height="30">&nbsp;<font color="red" size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font>
    <a href="javascript:CloseWindow();">
	  <img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a>
    </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" >
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Previous School:<input type="text" name="starts_with2" value="<%=WI.fillTextValue("starts_with2")%>" size="25" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		   style="font-size:12px" onKeyUp = "AutoScrollList('studdata_entry.starts_with2','studdata_entry.prev_school',true);"> 
      </td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="25" bgcolor="#FFFFFF">&nbsp;</td>
<%
        if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(2),"");
        else
    	    strTemp = WI.fillTextValue("prev_school");%>	  
      <td width="90%" bgcolor="#FFFFFF"><select name="prev_school">
            <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%>
          </select></td>
      <td width="8%" bgcolor="#FFFFFF"><a href='javascript:PageAction(1);'><img src="../../../images/edit.gif" border="0"></a></td>
    </tr>
  </table>
  <table  bgcolor="#F4F4F4" width="100%" border="0" cellpadding="0" cellspacing="0" >

    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%">Prep/Proper</td>
      <td width="78%">
      <%
        if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(10));
        else
		    strTemp = WI.fillTextValue("prep_prop_stat");%>
      <select name="prep_prop_stat">
	  	  <option value="0"> N / A </option>
          <%if(strTemp.equals("1")){%>	  
          <option value="1" selected>Preparatory</option>
		  <%}else{%>
          <option value="1">Preparatory</option>
          <%} if(strTemp.equals("2")){%>
          <option value="2" selected>Proper</option>
          <%}else{%>
          <option value="2">Proper</option>
          <%}%>
      </select>  </td>
      <td width="8%"><a href='javascript:PageAction(2);'><img src="../../../images/edit.gif" border="0"></a> </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">School Year </td>
      <td height="25" colspan="3">
	  <%if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(8),"");
        else
	      strTemp = WI.fillTextValue("sy_from");%>
      <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
         <%if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(9),"");
        else
	      strTemp = WI.fillTextValue("sy_to");%>
        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
      <td width="8%" rowspan="2"><a href='javascript:PageAction(3);'><img src="../../../images/edit.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Term Type</td>
      <td width="21%" height="25">
      <%if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(25),"");
        else
        	strTemp = WI.fillTextValue("term_type");%>
	  <select name="term_type">
<%=dbOP.loadCombo("TERM_TYPE_REF","TERM_NAME"," from G_SHEET_FINAL_TRANS_TERM where IS_INVALID=0 order by TERM_TYPE_REF",strTemp,false)%>
	  </select>
			
<!--
      <select name="term_type">
          <option value="1">SEMESTER</option>
          <%if(strTemp.equals("2")){%>
          <option value="2" selected>TRIMESTER</option>
          <%}else{%>
          <option value="2">TRIMESTER</option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>ANNUAL</option>
          <%}else{%>
          <option value="3">ANNUAL</option>
          <%}if(strTemp.equals("4")){%>
          <option value="4" selected>QUARTER</option>
          <%}else{%>
          <option value="4">QUARTER</option>
          <%}%>
        </select> 
-->		</td>
      <td width="10%">Year Level </td>
      <td width="47%"><%
        if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(11),"");
        else
	        strTemp = WI.fillTextValue("year_level");%>
        <select name="year_level">
          <option value="" >N/A</option>		
          <%if(strTemp.equals("1")){%>
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
        </select>
        &nbsp;&nbsp;&nbsp;Term
        <%if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(12),"");
        else
        	strTemp = WI.fillTextValue("semester");%>
        <select name="semester">
          <option value="1">1st </option>
          <%if(strTemp.equals("2")){%>
          <option value="2" selected>2nd </option>
          <%}else{%>
          <option value="2">2nd </option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd </option>
          <%}else{%>
          <option value="3">3rd </option>
          <%}if(strTemp.equals("4")){%>
          <option value="4" selected>4th </option>
          <%}else{%>
          <option value="4">4th </option>
          <%}if(strTemp.equals("0")){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td width="2%" height="18">&nbsp;</td>
      <td width="12%" height="18">&nbsp;</td>
      <td height="18" colspan="3">&nbsp;</td>
      <td>&nbsp;      </td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#F4F4F4">	
    <tr>
      <td height="18">&nbsp;</td>
      <td width="90%" height="18">&nbsp;<%
      if (vRetResult != null && vRetResult.size()>0){
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(13),"");
       }else
	      strTemp = WI.fillTextValue("is_internship");%>
		  
        <%if(strTemp.equals("1")){
			strTemp = "checked"; 
		  }else{
		  	strTemp = "";	
		  }
		%>
       <input name="is_internship" type="checkbox" value="1" <%=strTemp%> onClick="showBranch('branch1');">
      <font size="1"> (check if INTERNSHIP/CLERKSHIP/CADETSHIP subject)</font>&nbsp;	  </td>
      <td width="8%" height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="20">&nbsp;</td>
      <td height="25" colspan="2">
<span  class="branch" id="branch1" >
	  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="border: solid 1px 1px 1px 1px #FF0000">
          <tr>
            <td width="92%">Inclusive date of internship/clerkship :
              <%
        if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(20),"");
        else
	        strTemp = WI.fillTextValue("internship_date_fr");%>
              <input name="internship_date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
              <a href="javascript:show_calendar('form_.internship_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;&nbsp;to 
        &nbsp;&nbsp;
        <%if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(21),"");
        else
        	strTemp = WI.fillTextValue("internship_date_to");%>
        <input name="internship_date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.internship_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp; </td>
            <td width="8%"><a href='javascript:PageAction(4);'><img src="../../../images/edit.gif" border="0"></a></td>
          </tr>
          <tr>
            <td>Place taken : 
        <%
        if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(22),"");
        else
	        strTemp = WI.fillTextValue("internship_place");%>
        <input name="internship_place" type="text" size="60" maxlength="128" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td>Duration : 
	     <%
	     if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(23),"");
        else
		     strTemp = WI.fillTextValue("internship_dur");%>
        <input name="internship_dur" type="text" size="5" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
		<%
		if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(24),"");
        else
			strTemp = WI.fillTextValue("internship_dur_unit");%>
        <select name="internship_dur_unit">
          <option value="0">Hours</option>
          <%if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Weeks</option>
          <%}else{%>
          <option value="1">Weeks</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Months</option>
          <%}else{%>
          <option value="2">Months</option>
          <%}%>
        </select></td>
            <td>&nbsp;</td>
          </tr>
        </table>
</span>		</td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="9" ><hr size="1"></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="2" align="center" ><font color="#0000FF" size="1" ><a href='javascript:PageAction(5);'><img src="../../../images/edit.gif" border="0"></a></font></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="23%"  height="25" ><div align="left"><font size="1"><strong><br>
      SUBJECT CODE</strong></font></div></td>
      <td width="39%" ><font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td width="7%" ><font size="1"><strong>CREDITS EARNED</strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>UNITS</strong></font></td>
      <td width="6%" ><font size="1"><strong>FINAL GRADE</strong></font></td>
      <td width="7%" ><font size="1"><strong>REMARKS</strong></font></td>
      <td width="6%" ><font size="1"><strong>ACCRE<br>
      CREDIT</strong></font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" >
      <%if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(5),"");
        else
        	strTemp = request.getParameter("subject");%>
      <select name="subject" onChange="ReloadPage();" style="font-size:11px; width:165px">
          <option value="0">Enter another sub/code</option>
          <%=dbOP.loadCombo("sub_index","sub_code"," from subject where is_del=0 order by sub_code asc",strTemp,false)%>
        </select></td>
      <td ><span style="font-size:11px">
        <%=WI.getStrValue(dbOP.mapOneToOther("SUBJECT","sub_index",request.getParameter("subject"),"SUB_NAME",null))%></span></td>
      <td >
      <%if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(14),"");
        else
        	strTemp = WI.fillTextValue("credit_earned");%>
        <input name="credit_earned" type="text" size="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
      <td >
      <%if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(15),"");
        else
        	strTemp = WI.fillTextValue("unit");%>
      <select name="unit">
          <option >Unit</option>
          <%if(strTemp.compareTo("Hour") ==0){%>
          <option selected>Hour</option>
          <%}else{%>
          <option>Hour</option>
          <%}if(strTemp.compareTo("Month") ==0){%>
          <option selected>Month</option>
          <%}else{%>
          <option>Month</option>
          <%}if(strTemp.compareTo("Weeks") ==0){%>
          <option selected>Weeks</option>
          <%}else{%>
          <option>Weeks</option>
          <%}%>
        </select></td>
      <td >
      <%if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(16),"");
        else
        	strTemp = WI.fillTextValue("grade");%>
      <input name="grade" type="text" size="5" maxlength="12" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
      <td >
       <%if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(17),"");
        else
        	strTemp = WI.fillTextValue("remark_index");%>
      <select name="remark_index">
          <%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",strTemp, false)%>
        </select></td>
      <td >
      <%if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(19),"");
        else
        	strTemp = WI.fillTextValue("accredited_credit");%>
      <input name="accredited_credit" type="text" size="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" value="<%=strTemp%>"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%
if(request.getParameter("subject") == null || request.getParameter("subject").compareTo("0") ==0){%>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="28%">
      <%if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(6),"");
        else
        	strTemp = WI.fillTextValue("sub_code");%>
      <input type="text" name="sub_code" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <font size="1">(enter code)</font></td>
      <td width="59%">
       <%if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(7),"");
        else
        	strTemp = WI.fillTextValue("sub_name");%>
      <input type="text" name="sub_name" size="45" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      <font size="1">(enter name)</font></td>
    </tr>
    <%}//end of displaying if subject does not exist
%>
    <tr> 
      <td>&nbsp;</td>
      <td  height="18" colspan="2" ><font color="#0000FF" size="1" ><strong>EQUIV. 
        SUBJECT CODEE ::: SUBJECT TITLE</strong>&nbsp; (only if subjects is passed)</font></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="2" >
      <%if (vRetResult != null && vRetResult.size()>0)
	        strTemp = WI.getStrValue((String)vRetResult.elementAt(18),"");
        else
        	strTemp = WI.fillTextValue("equiv_code");%>      
		<select name="equiv_code" style="font-size:11px; width:700px" onChange="ReloadPage();">
        <option value="">Select a subject</option>
        <%=dbOP.loadCombo("SUB_INDEX","SUB_CODE +'&nbsp;&nbsp;&nbsp;('+sub_name+')'"," from SUBJECT where IS_DEL=0 order by sub_code asc",strTemp,false)%>
      </select>      &nbsp; <a href='javascript:PageAction(5);'></a></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
      <td height="25">
	  <input type="input" name="set_focus" size="1" maxlength="1" readonly
 	style="background-color: #ffffff;border-style: inset;border-color: #ffffff; border-width: 0px"></td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="firstRun" value="<%=WI.fillTextValue("strFirstRun")%>">
<input type="hidden" name="degree_type" value="<%=strDegreeType%>">
<input type="hidden" name="student_type" value="<%=WI.fillTextValue("student_type")%>">
<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->

<%
if(strCurInfo != null){%>
<input type="hidden" name="cur_index" value="<%=strCurInfo[0]%>">
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
