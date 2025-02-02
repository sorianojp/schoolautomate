<%@ page language="java" import="utility.*,enrollment.ReportFeeAssessment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	String[] astrConvertSem= {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

	WebInterface WI = new WebInterface(request);

//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-SAO-Scholarship","scholarship_list.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
							//							"fee_adjustment.jsp");
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
Vector vRetResult = null;
ReportFeeAssessment rFA = new ReportFeeAssessment();
if(WI.fillTextValue("showdetails").length() > 0) {
	vRetResult = rFA.getStudListAssistance(dbOP,request);
	if(vRetResult == null) {
		strErrMsg = rFA.getErrMsg();
	}
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCLDH = true;//strSchCode.startsWith("CLDH");

boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css"  type="text/css" rel="stylesheet">
<link href="../../../css/tableBorder.css"  type="text/css" rel="stylesheet">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
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
	font-size: 10px;	
    }

    TD.thinborder {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

-->
</style>
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js" type="text/javascript"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js" type="text/javascript"></script>
<script language="JavaScript">
<!--
function ReloadPage()
{ 
	document.form_.showdetails.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_"); 
}

function ShowDetails(){
	document.form_.print_page.value = "";
	document.form_.showdetails.value = 1;
	this.SubmitOnce("form_"); 
}

function PrintPg(){

	var strInfo = "<div align=\"center\"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong>"+"<br>";
	strInfo +="<font size =\"2\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
	strInfo +="<font size =\"2\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font>";
	strInfo +="<font size =\"2\"><%=SchoolInformation.getInfo2(dbOP,false,false)%></font>";
	strInfo +="</div><br>";
	document.bgColor = "#FFFFFF";
	
	document.getElementById('header').deleteRow(0);
	document.getElementById('header').deleteRow(0);
	document.getElementById('header').deleteRow(0);
	document.getElementById('header').deleteRow(0);	
	document.getElementById('header').deleteRow(0);	
	document.getElementById('header').deleteRow(0);	
	document.getElementById('header').deleteRow(0);	
	//strTemp is set in Java code above
	var obj = document.getElementById('searchTable');
	obj.deleteRow(0);
	if(obj.getElementsByTagName("tr")[0])
		obj.deleteRow(0);
	if(obj.getElementsByTagName("tr")[0])
		obj.deleteRow(0);
	if(obj.getElementsByTagName("tr")[0])
		obj.deleteRow(0);
	
	document.getElementById('myADTable').deleteRow(0);
	//this.insRow(0, 1, strInfo);
	window.print();
}

-->
</script>

<body bgcolor="#D2AE72">

<form name="form_" method="post" action="./scholarship_list.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A">
      <td height="24" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          STUDENTS WITH EDUCATIONAL ASSISTANCE PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="24" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td colspan="3" style="color:#0000FF">NOTE : At first time this report takes time to generate</td>
    </tr>
    
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">School Year :</td>
      <td width="33%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> 
        <input name="sy_from" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' value="<%=strTemp%>" size="4" maxlength="4">
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> 
        <input name="sy_to" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  readonly="yes">
        - 
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
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
        </select> </td>
      <td width="45%"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date Posted : </td>
      <td colspan="2"><input name="date_posted_fr" type="text" class="textbox" id="date_attendance" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_posted_fr")%>" size="10" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.date_posted_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> to
        <input name="date_posted_to" type="text" class="textbox" id="date_attendance2" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_posted_to")%>" size="10" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.date_posted_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
<%if(strSchCode.startsWith("UI")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" style="font-size:11px; font-weight:bold; color:#0000FF">
<%
strTemp = WI.fillTextValue("is_basic");
if(strTemp.length() > 0) 
	strTemp = " checked";
%>
		  <input type="checkbox" name="is_basic" value="1"<%=strTemp%> onClick="ReloadPage();"> Process Report for Grade School	  </td>
    </tr>
<%}%>
    <tr> 
      <td height="19" colspan="4"><hr size="1" color="#008080"></td>
    </tr>
  </table>
<% if (WI.fillTextValue("sy_from").length()!=0 && WI.fillTextValue("sy_to").length()!= 0) {%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0" id="searchTable">
    <tr> 
      <td height="32">&nbsp;</td>
      <td width="27%">Educational Assistance Type : </td>
      <td width="33%"><select name="assistance0" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%=dbOP.loadCombo("distinct MAIN_TYPE_NAME","MAIN_TYPE_NAME"," from FA_FEE_ADJUSTMENT where is_del=0 and is_valid=1 and "+
		  "tree_level=0 and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
		  " and (semester = "+WI.fillTextValue("semester")+" or semester is null) order by FA_FEE_ADJUSTMENT.MAIN_TYPE_NAME asc", 
		  request.getParameter("assistance0"), false)%> </select></td>
      <td width="39%"><a href="javascript:ShowDetails()"><img src="../../../images/view.gif" width="40" height="31" border="0"></a><font size="1">click 
        to view list of students</font></td>
    </tr>
    <tr> 
      <td height="32">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"> <%
strTemp = request.getParameter("assistance0");
if(strTemp != null && strTemp.compareTo("0") != 0 && strTemp.length() > 0){
strTemp = ConversionTable.replaceString(strTemp,"'","''");
strTemp = " from FA_FEE_ADJUSTMENT where is_del=0 and is_valid=1 and tree_level=1 and MAIN_TYPE_NAME='"+strTemp+
"' and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+ 
" and (semester = "+WI.fillTextValue("semester")+" or semester is null) order by SUB_TYPE_NAME1 asc";
%> <select name="assistance1" onChange="ReloadPage();">
          <option value="">Select</option>
          <%=dbOP.loadCombo("SUB_TYPE_NAME1","SUB_TYPE_NAME1",strTemp, 
	request.getParameter("assistance1"), false)%> </select> <%
		strTemp = request.getParameter("assistance1");
		if(strTemp != null && strTemp.compareTo("0") != 0 && strTemp.length() > 0){
		strTemp = ConversionTable.replaceString(strTemp,"'","''");
		strTemp = " from FA_FEE_ADJUSTMENT where is_del=0 and is_valid=1 and tree_level=2 and MAIN_TYPE_NAME='"+
		ConversionTable.replaceString(request.getParameter("assistance0"),"'","''")+"' and SUB_TYPE_NAME1='"+
		strTemp+"' and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
		  " and semester = "+WI.fillTextValue("semester")+" order by SUB_TYPE_NAME2 asc";
		%> <select name="assistance2" onChange="ReloadPage();">
          <option value="">Select</option>
          <%=dbOP.loadCombo("SUB_TYPE_NAME2","SUB_TYPE_NAME2",strTemp, request.getParameter("assistance2"), false)%> 
        </select> <%}

		strTemp = request.getParameter("assistance2");
		if(strTemp != null && strTemp.compareTo("0") != 0 && strTemp.length() > 0){
		strTemp = ConversionTable.replaceString(strTemp,"'","''");
		strTemp = " from FA_FEE_ADJUSTMENT where is_del=0 and is_valid=1 and tree_level=3 and MAIN_TYPE_NAME='"+
		ConversionTable.replaceString(request.getParameter("assistance0"),"'","''")+"' and SUB_TYPE_NAME1='"+
		ConversionTable.replaceString(request.getParameter("assistance1"),"'","''")+"' and SUB_TYPE_NAME2='"+strTemp+
		"' and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
		  " and semester = "+WI.fillTextValue("semester")+" order by SUB_TYPE_NAME3 asc";
		%> <select name="assistance3" onChange="ReloadPage();">
          <option value="0">Select</option>
          <%=dbOP.loadCombo("SUB_TYPE_NAME3","SUB_TYPE_NAME3",strTemp, request.getParameter("assistance3"), false)%> 
        </select> <%}//for last condition.
}%> </td>
    </tr>
<%if(WI.fillTextValue("is_basic").length() == 0){%>
    <tr> 
      <td width="1%" height="32">&nbsp;</td>
      <td colspan="3">College : 
        <select name="c_index" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from college where is_del = 0",request.getParameter("c_index"), false)%> 
	  </select></td>
    </tr>
<% if (WI.fillTextValue("c_index").length() > 0) {%>	
    <tr>
      <td height="32">&nbsp;</td>
      <td colspan="3">Department : 
        <select name="d_index" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%=dbOP.loadCombo("d_index","d_name"," from department where c_index = "+ WI.fillTextValue("c_index"),WI.fillTextValue("d_index"), false)%> 
	    </select>
	  </td>
    </tr>
<%}
}//do not show for basic.. %>
  </table>
<%
if (vRetResult != null && vRetResult.size() > 0)  {
	if (WI.fillTextValue("assistance0").length() == 0){
		strTemp = "ALL ";
	}else{
		strTemp = (String)vRetResult.elementAt(5);
	}
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable">
    <tr> 
      <td height="25" colspan="6"><div align="right"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a><font size="1">click 
          to print list</font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="6"><div align="center"><font size="2"><strong><u>LIST 
          OF STUDENTS WITH EDUCATIONAL ASSISTANCE : <%=strTemp%></u></strong></font><br>
          AY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>, <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>
		<%if(WI.fillTextValue("date_posted_fr").length() > 0) {%>
			&nbsp; :::: &nbsp;<font size="1">Cut-off Date : <%=WI.fillTextValue("date_posted_fr")%> 
			<%=WI.getStrValue(WI.fillTextValue("date_posted_to")," to ", "", "")%></font>
		<%}%>
		  
		  </div></td>
      <%if(bolIsCLDH){%><%}%>
    </tr>
    <tr> 
      <td height="25" colspan="6"><strong>TOTAL STUDENTS :<%=(String)vRetResult.elementAt(0)%></strong></td>
      <%if(bolIsCLDH){%><%}%>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="12%" height="25" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID</strong></font></div></td>
      <td width="23%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT NAME</strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>COURSE<%if(!bolIsBasic){%>/MAJOR<%}%></strong></font></div></td>
      <%if(bolIsCLDH){%>
	  <td width="10%" class="thinborder" align="center" style="font-weight:bold">DATE POSTED</td>
      <%}%>
	  <td width="20%" class="thinborder"> <div align="center"><font size="1"><strong>GRANT NAME</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>DISCOUNTS</strong></font></div></td>
    </tr>
<% 
/**
 * [0] = total Student.   [1] = total Disc Amt.
 *  [0] student index [1] Stud Name [2] fa_fa_indexs  [3] main adjustment 
 *  [4] sub adjustment type 1  [5] sub adjustment type 2  [6] sub adjustment type 3
 *  [7] discount   [8] discount unit   [9] discount on  [10] year level 
 *  [11] id number  [12]  course  [13]  major  [14]  amount
 *   
 */
 String strCollege = ""; String strDepartment = "";
 boolean bolChanged = false;
 for (int i =2; i < vRetResult.size() ; i+=16) {
	bolChanged = false;
	if (vRetResult.elementAt(i+13) != null &&  strCollege.compareTo((String)vRetResult.elementAt(i+13)) != 0){
		bolChanged = true;
		strCollege = (String)vRetResult.elementAt(i+13);
	}
	if (vRetResult.elementAt(i+14) != null && strDepartment.compareTo((String)vRetResult.elementAt(i+14)) != 0){
		bolChanged  = true;
		strDepartment = (String)vRetResult.elementAt(i+14);
	}
	strTemp = (String)vRetResult.elementAt(i+10);
	if ((String)vRetResult.elementAt(i+11) !=null){
		strTemp+= "(" + (String)vRetResult.elementAt(i+11) + ")";
	}
	
	if(bolIsBasic)	
		strTemp = dbOP.getBasicEducationLevel(Integer.parseInt(strTemp));
	
	if (bolChanged){
%>
    <tr> 
      <td height="25" colspan="6" class="thinborderBOTTOMLEFT"><%if(!bolIsBasic){%>College : <%}%><strong><%=strCollege%><%=WI.getStrValue(strDepartment," &nbsp;&nbsp;&nbsp;&nbsp; Department :","","")%></strong></td>
      <%if(bolIsCLDH){%><%}%>
    </tr>
<%}%>
    <tr> 
      <td height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>
      <%if(bolIsCLDH){%>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+15)%></td>
      <%}%>
	  <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+3)%><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"/","","")%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></font></td>
    </tr>
    <%}//END OF FOR LOOP%>
    
  </table>
    <%}//if(vRetResult != null)

}//if (WI.fillTextValue("sy_from").length()!=0 && WI.fillTextValue("sy_to").length()!= 0)%>
  <input type="hidden" name="showdetails">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>