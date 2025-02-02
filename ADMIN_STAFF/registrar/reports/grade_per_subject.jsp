<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.sub_name.value = document.form_.sub_index[document.form_.sub_index.selectedIndex].text;
	//this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPage() {
 	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	
	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function showHideGWA() {
	var iSelGwaCon = document.form_.gwa_con.selectedIndex;
	if(iSelGwaCon == 0) {
		hideLayer('gwa_fr_label');
		hideLayer('gwa_to_label');
	}
	else if(iSelGwaCon == 3) {
		showLayer('gwa_fr_label');
		showLayer('gwa_to_label');
	}
	else {
		showLayer('gwa_fr_label');
		hideLayer('gwa_to_label');
	}
}
</script>

<body bgcolor="#D2AE72" onLoad="showHideGWA();">
<%@ page language="java" import="utility.*,enrollment.ReportRegistrarExtn,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	//String[] astrConvertYear ={"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Grade per subject","grade_per_subject.jsp");
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
						//								"Registrar Management","REPORTS",request.getRemoteAddr(),
							//							"grade_per_subject.jsp");
if(request.getSession(false).getAttribute("userIndex") == null)
	iAccessLevel = -1;

	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
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
ReportRegistrarExtn RR = new ReportRegistrarExtn();
Vector vRetResult      = null;

if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = RR.getGradePerSubject(dbOP, request);
	if(vRetResult == null) {
		strErrMsg = RR.getErrMsg();
	}
}


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsCGH = strSchCode.startsWith("CGH");
boolean bolShowPercent = false;
boolean bolHideRemark  = false;
%>
<form action="./grade_per_subject.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: GRADE PER SUBJECT ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY-Term</td>
      <td>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");	
//System.out.println((String)request.getSession(false).getAttribute("cur_sch_yr_from"));  
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");	  
%>
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
- 
<select name="semester">
  <option value="1">1st Sem</option>
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	
if(strTemp == null) 
	strTemp = "";
if(strTemp.compareTo("2") ==0){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.compareTo("3") ==0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}if(strTemp.compareTo("4") ==0){%>
  <option value="4" selected>4th Sem</option>
  <%}else{%>
  <option value="4">4th Sem</option>
  <%}if(strTemp.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}%>
</select>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="image" src="../../../images/refresh.gif" onClick="ReloadPage();">       </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="10%">Subject</td>
      <td width="88%"><font size="1">
        <input type="text" name="scroll_sub" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'form_');" class="textbox">
(enter sub code to scroll)</font>
		
		&nbsp;&nbsp;&nbsp;<%if(strSchCode.startsWith("CGH")){%>
		<a href="./grade_per_subject_top.jsp" style="text-decoration:none">
		<font style="font-size:11px; font-weight:bold; color:#0000FF">Go to Top student Per subject</font></a>
<%}%>
	</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><select name="sub_index" style="font-size:11px">
        <%=dbOP.loadCombo("sub_index","sub_code +' ('+sub_name+')' as sub_c"," from subject where IS_DEL=0 order by sub_c asc",
  		request.getParameter("sub_index"), false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Student ID : 
        <input name="stud_id" type="text" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="26" height="24" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" align="left">
	  	<table bgcolor="#DDDDDD" class="thinborderALL" cellpadding="0" cellspacing="0" border="0" width="95%">
<%
strTemp = WI.fillTextValue("remove_nograde");
if(strTemp.length() > 0) 
	strTemp = " checked";
%>
	  		<tr>
				<td width="45%" class="thinborderRIGHT">
				<input type="checkbox" name="remove_nograde" value="1" <%=strTemp%>>				
				Remove records with &quot;no grade encoded&quot; </td>
				<td width="55%" class="thinborderNONE">
<%
strTemp = WI.fillTextValue("show_nograde");
if(strTemp.length() > 0) 
	strTemp = " checked";
%>				<input type="checkbox" name="show_nograde" value="1"<%=strTemp%>>Show only records with &quot;no grade encoded&quot;</td>
			</tr>
<%//if(bolIsCGH){
if(WI.fillTextValue("show_percent").length() > 0) {
	strTemp = " checked";
	bolShowPercent = true;
}
else	
	strTemp = "";
%>
	  		<tr>
	  		  <td class="thinborderRIGHT"><input type="checkbox" name="show_percent" value="1" <%=strTemp%>>
Show Grade Percentage </td>
	  		  <td class="thinborderNONE">
			  <%
			  strTemp = WI.fillTextValue("sort_by_grade");
			  if(strTemp.length() > 0) 
			  	strTemp = " checked";
			  %>
			  <input type="checkbox" name="sort_by_grade" value="1"<%=strTemp%>>
  		      Sort by Grade 
			  &nbsp;&nbsp;
			  <%strTemp = WI.fillTextValue("order");
			  if(strTemp.equals("asc") || strTemp.length() == 0)
			  	strTemp = " checked";
			  else	
			  	strTemp = "";
			  %>
			  <input name="order" type="radio" value="asc"<%=strTemp%>> Asc
			  <%if(strTemp.length() == 0) 
			  	strTemp = " checked";
			   else	
				strTemp = "";
			   %>
			  <input name="order" type="radio" value="desc"<%=strTemp%>> Desc			  </td>
  		  </tr>
	  		<tr>
	  		  <td class="thinborderRIGHT">
<%
if(WI.fillTextValue("hide_remark").length() > 0) {
	strTemp = " checked";
	bolHideRemark = true;
}
else	
	strTemp = "";
%>
			  <input type="checkbox" name="hide_remark" value="1" <%=strTemp%>>
  		      Hide Remark :: Show Top 
<input name="top_" type="text" size="3" maxlength="3" value="<%=WI.fillTextValue("top_")%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','top_');style.backgroundColor='white'"
		onKeyup="AllowOnlyFloat('form_','top_');" style="font-size:12px">			  
			  
			  </td>
	  		  <td class="thinborderNONE">Show Grade : <span class="thinborder">
	  		    <select name="gwa_con" onChange="showHideGWA();">
                  <option value="0">No Filter</option>
                  <%
strTemp = WI.fillTextValue("gwa_con");
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
                  <option value="1"<%=strErrMsg%>>Greater than</option>
                  <%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
                  <option value="2"<%=strErrMsg%>>Less than</option>
                  <%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
                  <option value="3"<%=strErrMsg%>>Between</option>
                </select>
&nbsp;
<input name="gwa_fr" type="text" size="3" maxlength="3" value="<%=WI.fillTextValue("gwa_fr")%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','gwa_fr');style.backgroundColor='white'"
		onKeyup="AllowOnlyFloat('form_','gwa_fr');" style="font-size:12px" id="gwa_fr_label">
<label id="gwa_to_label">&nbsp;to&nbsp;
<input name="gwa_to" type="text" size="3" maxlength="3" value="<%=WI.fillTextValue("gwa_to")%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','gwa_to');style.backgroundColor='white'"
		onKeyup="AllowOnlyFloat('form_','gwa_to');" style="font-size:12px" >
</label>
              </span></td>
  		  </tr>
<%//}%>
	  	</table>	  </td>
    </tr>
    
    <tr> 
      <td colspan="3" height="20"><hr size="1"></td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0){%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr>
      <TD>&nbsp;</TD>
      <TD align="right"><a href='javascript:PrintPage();'><img src="../../../images/print.gif" width="58" height="26" border="0"></a> <font size="1">click to print</font></TD>
    </tr>
    <tr>
      <TD colspan="2">
        <div align="center">
        	<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
            <strong><%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>, 
			<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>        </strong></div>      </TD>
    </tr>
<%
strTemp = WI.fillTextValue("sub_name");
//int iIndexOf = strTemp.indexOf(":::");
%>	
    <tr>
      <td colspan="2">&nbsp;&nbsp;&nbsp;Subject : <%=strTemp%></TD>
    </tr>
    <tr> 
      <TD width="41%">&nbsp;&nbsp;&nbsp;Total Count :<strong> <%=vRetResult.size() / 5%></strong></TD>
      <TD width="59%" align="right"><font size="1">Date and Time printied : <b><%=WI.getTodaysDateTime()%></b></font></TD>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="8%" class="thinborder" align="center"><strong><font size="1">SL NO </font></strong></td> 
      <td width="21%" height="25" class="thinborder" align="center"><font size="1"><strong>STUDENT ID</strong></font></td>
      <td width="32%" class="thinborder" align="center"><font size="1"><strong>STUDENT NAME<br>(fname,mi,lname) </strong></font></td>
      <td width="14%" class="thinborder"><div align="center"><strong><font size="1">UNIT EARNED </font></strong></div></td>
      <td width="11%" align="center" class="thinborder"><strong><font size="1">GRADE</font></strong></td>
<%if(bolShowPercent){%>
      <td width="11%" align="center" class="thinborder"><strong><font size="1">GRADE %ge</font></strong></td>
<%}if(!bolHideRemark) {%>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>REMARK</strong></font></div></td>
<%}
String strGradeValue = null;
for(int i =0; i < vRetResult.size(); i += 6){
	strGradeValue = WI.getStrValue((String)vRetResult.elementAt(i + 2));
	if(bolIsCGH && strGradeValue != null && (strGradeValue.endsWith("0") || strGradeValue.length() == 3) && strGradeValue.length() > 1)
		strGradeValue = strGradeValue+"0";
	strTemp = (String)vRetResult.elementAt(i + 4);
	if(strTemp != null && bolIsCGH) {
		if(strTemp.endsWith(".00"))
			strTemp = strTemp.substring(0,strTemp.length() - 1);
		else if(strTemp.indexOf(".") == -1)
			strTemp = strTemp+".0";
	}
%>
    <tr>
      <td class="thinborder">&nbsp;<%=i/6 + 1%></td> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
	  <td class="thinborder">&nbsp;<%=strTemp%></td>
	  <td class="thinborder">&nbsp;<%=strGradeValue%></td>
<%if(bolShowPercent){%>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 5))%></td>
<%}if(!bolHideRemark){%>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
<%}%>
    </tr>
<%}//end of for loop.%>
  </table>

<%}//only if vRetResult not null%>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>

<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

<input type="hidden" name="sub_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>