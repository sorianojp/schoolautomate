<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../../jscript/date-picker.js"></script>
<script language="javascript">
function StudSearch() {
	document.form_.print_page.value = '';
	
	var pgLoc = "../../../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

var AjaxCalledPos;
function AjaxMapName(strPos) {
		document.form_.print_page.value = '';
	
		AjaxCalledPos = strPos;
		if(strPos == "1") {
			document.getElementById("stud_info1").innerHTML = "...";
			document.getElementById("stud_info2").innerHTML = "...";
		}
		
		var strCompleteName;
		if(strPos == "1")
			strCompleteName = document.form_.stud_id.value;
		else	
			strCompleteName = document.form_.emp_id.value;
			
		if(strCompleteName.length == 0)
			return;
		
		var objCOAInput;
		if(strPos == "1")
			objCOAInput = document.getElementById("coa_info");
		else	
			objCOAInput = document.getElementById("coa_info2");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);
		if(strPos == "2")
			strURL += "&is_faculty=1";
		//if(document.form_.account_type[1].checked) //faculty
		//	strURL += "&is_faculty=1";
		//alert(strURL);
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.print_page.value = '';
	
	if(AjaxCalledPos == "2"){
		document.form_.emp_id.value = strID;
		return;
	}
	document.form_.stud_id.value = strID;
	document.form_.stud_id.focus();
	
	document.getElementById("stud_info1").innerHTML = " == Press press enter to load information. == ";
	document.getElementById("stud_info2").innerHTML = " == Press press enter to load information. == ";
	//alert(strUserIndex);
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	if(AjaxCalledPos == "1")
		document.getElementById("coa_info").innerHTML = strName;
	else	
		document.getElementById("coa_info2").innerHTML = strName;
}

function PrintPg() {
	document.form_.print_page.value = '1';
	document.form_.submit();
}
function PrintOnLoad() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);

	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
	
	boolean bolIsPrint = WI.fillTextValue("print_page").equals("1");//System.out.println("bolIsPrint : "+bolIsPrint);
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration-Registrar-report-Others-LOA","loa.jsp");
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
					//									"Guidance & Counseling","GOOD MORAL CERTIFICATION",request.getRemoteAddr(),
					//									"cgh_certificate_main.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

String strStudID    = WI.fillTextValue("stud_id");
String strStudIndex = null;
String strSQLQuery  = null;

java.sql.ResultSet rs = null;
Vector vStudInfo      = new Vector();

if(strStudID.length() > 0) {
	strSQLQuery = "select user_index, fname, mname, lname from user_table where id_number = '"+
		strStudID+"'";
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		vStudInfo.addElement(WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4));
		strStudIndex = rs.getString(1);
	}
	rs.close();
	if(vStudInfo.size() > 0) {
		strSQLQuery = "select course_offered.course_code,major_name,sy_from,semester, year_level from stud_curriculum_hist "+
			"join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
			"left join major on (major.major_index = stud_curriculum_hist.major_index) "+
			"join semester_sequence on (semester_val = semester)"+
			" where stud_curriculum_hist.is_valid = 1 and stud_curriculum_hist.user_index = "+strStudIndex+
			" order by sy_from desc, semester desc";
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			if(rs.getString(2) != null) 
				vStudInfo.addElement(rs.getString(1) +" :: "+rs.getString(2));
			else
				vStudInfo.addElement(rs.getString(1));
			vStudInfo.addElement(rs.getString(3)+" - "+rs.getString(4));	
		}
		rs.close();
		if(vStudInfo.size() == 1)
			strErrMsg = "Student enrollment information not found.";
	}
}
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
enrollment.CGHAddition cghAddition = new enrollment.CGHAddition();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(cghAddition.operateOnLOA(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = cghAddition.getErrMsg();
	else {
		strErrMsg = "Operation Successful.";
		strPreparedToEdit = "0";
	}
}
Vector vEditInfo = null;

Vector vRetResult = cghAddition.operateOnLOA(dbOP, request, 4);
if(strPreparedToEdit.equals("1")) {
	vEditInfo = cghAddition.operateOnLOA(dbOP, request, 3);
	if(vEditInfo == null) 
		strErrMsg = cghAddition.getErrMsg();
}

%>
<body <%if(bolIsPrint){%> onLoad="PrintOnLoad()" <%}%>>
<form action="./loa.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="1" id="myADTable1">
    <tr>
     <td width="100%" height="25"><div align="center"><strong>:::: 
          <font size="2" face="Verdana, Arial, Helvetica, sans-serif">LEAVE APPLICATION <font> ::::</strong></div></td>
    </tr>
    <tr >
      <td height="25" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="18%">Student ID</td>
      <td width="78%">
	  	<input name="stud_id" type="text"  value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUp="AjaxMapName('1');"><input type="image" src="../../../../../images/blank.gif" border="0">
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" id="myADTable3">
    <tr> 
      <td height="25">&nbsp;</td>
      <td> Student Name</td>
      <td height="25"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"><%if(vStudInfo != null && vStudInfo.size() > 0){%><%=vStudInfo.elementAt(0)%><%}%></label></td>
    </tr>
    <tr> 
      <td  width="4%"height="25">&nbsp;</td>
      <td width="18%" height="25">Course</td>
      <td height="25"><strong><label id="stud_info1"><%if(vStudInfo != null && vStudInfo.size() > 1){%><%=vStudInfo.elementAt(1)%><%}%></label></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">SY/Term</td>
      <td width="78%" height="25"><strong><label id="stud_info2"><%if(vStudInfo != null && vStudInfo.size() > 1){%><%=vStudInfo.elementAt(2)%><%}%></label></strong></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Current SY/Term </td>
      <td style="font-size:9px; color:#0000FF">
<%
	strTemp = WI.fillTextValue("cur_sy_from");
	if(strTemp.length() == 0) {
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
		if(strTemp == null)
			strTemp = "";
	}
%>
	  <input name="cur_sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> &nbsp;
	  <select name="cur_sem">
          <option value="1">1st Sem</option>
<%
	strTemp = WI.fillTextValue("cur_sem");
	if(strTemp.length() == 0) {
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		if(strTemp == null)
			strTemp = "";
	}
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select>
		Note : System puts AWOL in remark if student does not return on re-admission sy/term.
		</td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Effectivity of LOA </td>
      <td height="10">
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("LOA_FR_SY");
%>
	  <input name="LOA_FR_SY" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> &nbsp;
	  <select name="LOA_FR_SEM">
          <option value="1">1st Sem</option>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("LOA_FR_SEM");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select>
	  to 
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(13);
else	
	strTemp = WI.fillTextValue("loa_to_sy");
%>
	  <input name="loa_to_sy" type="text" size="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> &nbsp;
	  <select name="loa_to_sem">
          <option value=""></option>
<%
if(vEditInfo != null) 
	strTemp = WI.getStrValue(vEditInfo.elementAt(14));
else	
	strTemp = WI.fillTextValue("loa_to_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
<%}else{%>
          <option value="1">1st Sem</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select>
&nbsp;&nbsp;&nbsp;		
	  <input name="Submit2" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" value="Show List." onClick="document.form_.page_action.value='';document.form_.print_page.value='';document.form_.preparedToEdit.value=''">	  </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Date Filed </td>
      <td height="10">
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("date_filed");
%>
	<input name="date_filed" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_filed');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../../../images/calendar_new.gif" border="0"></a>	  </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Re-admission</td>
      <td height="10">
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("re_admission_sy");
%>
	  <input name="re_admission_sy" type="text" size="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> &nbsp;
	  <select name="re_admission_sem">
          <option value=""></option>
<%
if(vEditInfo != null) 
	strTemp = WI.getStrValue(vEditInfo.elementAt(6));
else	
	strTemp = WI.fillTextValue("re_admission_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
<%}else{%>
          <option value="1">1st Sem</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select>	  </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Advised By </td>
      <td height="10">
<%
if(vEditInfo != null) 
	strTemp = WI.getStrValue(vEditInfo.elementAt(10));
else	
	strTemp = WI.fillTextValue("advised_by");
%>
	  <input name="advised_by" type="text"  value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" maxlength="64"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Remarks</td>
      <td height="10">
<%
if(vEditInfo != null) 
	strTemp = WI.getStrValue(vEditInfo.elementAt(7));
else	
	strTemp = WI.fillTextValue("remarks");
%>
	  <input name="remarks" type="text"  value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">
<%if(!strPreparedToEdit.equals("1")){%>
	  <input name="Submit" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" value="Save" onClick="document.form_.page_action.value='1';document.form_.print_page.value='';">&nbsp;&nbsp;&nbsp;
<%}else if(vEditInfo != null) {%>
	  <input name="Submit" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" value="Edit" onClick="document.form_.print_page.value='';document.form_.page_action.value='2';document.form_.info_index.value=<%=vEditInfo.elementAt(0)%>">&nbsp;&nbsp;&nbsp;
	  <input name="Submit" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" value="Cancel" onClick="document.form_.print_page.value='';document.form_.page_action.value=''; document.form_.preparedToEdit.value=''">
<%}%>	  </td>
    </tr>
    <tr>
      <td height="30" colspan="3" align="right">
	  <a href="javascript:PrintPg();"><img src="../../../../../images/print.gif" border="0"></a>
	  	<font size="1">Print report</font>	  </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td height="25" colspan="11" class="thinborder">
	  <div align="center"><strong><font color="#0000FF">:: List of Student with LOA :: </font></strong></div></td>
    </tr>
    <tr>
      <td height="25" colspan="11" class="thinborder">&nbsp; Number of Students : <%=vRetResult.size()/15%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center"height="20">SL # </td> 
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Student ID </td>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Name</td>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Effectivity of LOA </td>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Date Filed </td>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Encoded By </td>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Re-Admission</td>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Remarks</td>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Advised By </td>
<%if(!bolIsPrint){%>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Edit</td>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Delete</td>
<%}%>
    </tr>
<%
String[] astrConvertSem = {"SU","FS","SS","TS"};
for(int i = 0; i < vRetResult.size(); i += 15){%>
    <tr>
      <td class="thinborder" style="font-size:9px;"><%=i/15 + 1%></td> 
      <td height="25" class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 11)%></td>
      <td class="thinborder" style="font-size:9px;"><%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i + 3))]%> <%=vRetResult.elementAt(i + 2)%>
	  	<%if(vRetResult.elementAt(i + 13) != null){%>
		to <%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i + 14))]%> <%=vRetResult.elementAt(i + 13)%>
		<%}%>	  </td>
      <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder" style="font-size:9px"><%=vRetResult.elementAt(i + 12)%></td>
      <td class="thinborder" style="font-size:9px">
	  	<%if(vRetResult.elementAt(i + 13) != null){%>
			<%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i + 6))]%> <%=vRetResult.elementAt(i + 5)%>
		<%}else{%>&nbsp;<%}%>	  </td>
      <td class="thinborder" style="font-size:9px"><%=WI.getStrValue(vRetResult.elementAt(i + 7),"&nbsp;")%></td>
      <td class="thinborder" style="font-size:9px"><%=WI.getStrValue(vRetResult.elementAt(i + 10),"&nbsp;")%></td>
<%if(!bolIsPrint){%>
      <td class="thinborder" style="font-size:9px">
	  <input type="button" value="Edit" onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='1';document.form_.info_index.value='<%=(String)vRetResult.elementAt(i)%>';document.form_.submit();">	  </td>
      <td class="thinborder" style="font-size:9px">
	  <input type="button" value="Delete" onClick="document.form_.page_action.value='0';document.form_.info_index.value='<%=(String)vRetResult.elementAt(i)%>'; document.form_.submit();">	  </td>
<%}%>
    </tr>
<%}%>
  </table>
<%}%>
<input type="hidden" name="print_page" value="">
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>