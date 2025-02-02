<%
if(request.getParameter("print_pg") != null && request.getParameter("print_pg").compareTo("1") ==0){%>
	<jsp:forward page="print_hepa_xray.jsp"/>
<%return;}%>

<%@ page language="java" import="utility.*,health.SchoolSpecific,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-Guidance-Reports-Other(Hepa/xRay)","hepa_xray.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
SchoolSpecific SS = new SchoolSpecific();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	SS.xRayHepaBReport(dbOP, request, 1);
	strErrMsg = SS.getErrMsg();
}
boolean bolIsHepa = WI.fillTextValue("test_type").equals("1");
if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = SS.xRayHepaBReport(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = SS.getErrMsg();
}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.form_.print_pg.value = "1";
	var strReportName = prompt("Please enter report name.");
	if(strReportName != null && strReportName.length > 0) 
		document.form_.report_name.value = strReportName;
	this.SubmitOnce("form_");	
}
function SelAll() {
	var iMaxCount = document.form_.max_disp.value;
	var bolIsChecked = document.form_.sel_all.checked;
	var vObj;
	for(i = 0; i < iMaxCount; ++i) {
		eval('vObj=document.form_.checkbox_'+i);
		if(!vObj)
			continue;
		if(bolIsChecked)
			vObj.checked = true;
		else	
			vObj.checked = false;
	}
}
var fieldOnFocus = -1;
function SelectBox(rowIndex) {
	eval('document.form_.checkbox_'+rowIndex+'.checked = true');
	fieldOnFocus = rowIndex;
}
function CopyRemark() {
	if(fieldOnFocus == -1) {
		alert("Please select a remark first before copying.");
		return;
	}
	var objRemark;
	eval('objRemark=document.form_.remark_'+fieldOnFocus);
	
	objRemark.value = document.form_.copy_remark[document.form_.copy_remark.selectedIndex].text;
}
</script>

<body>
<form action="./hepa_xray.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          <%if(!bolIsHepa){%>X-RAY<%}else{%>HEPA-B<%}%> Result Page ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">SY-Term</td>
      <td width="80%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null) 
	strTemp = "";
%>	  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' maxlength=4>
to
<%
if(strTemp.length() > 0)
	strTemp = Integer.toString(Integer.parseInt(strTemp) + 1);
%>
  <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
&nbsp;&nbsp;
<select name="semester">
  <option value="1">1st Sem</option>
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null) 
	strTemp = "";
if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
  <option value="2"<%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
  <option value="3"<%=strErrMsg%>>3rd Sem</option>
<%
if(strTemp.equals("0"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
  <option value="0"<%=strErrMsg%>>Summer</option>
</select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Year Level </td>
      <td><select name="year_level">
        <option value="">N/A</option>
        <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0)
{%>
        <option value="1" selected>1st</option>
        <%}else{%>
        <option value="1">1st</option>
        <%}if(strTemp.compareTo("2") ==0){%>
        <option value="2" selected>2nd</option>
        <%}else{%>
        <option value="2">2nd</option>
        <%}if(strTemp.compareTo("3") ==0)
{%>
        <option value="3" selected>3rd</option>
        <%}else{%>
        <option value="3">3rd</option>
        <%}if(strTemp.compareTo("4") ==0)
{%>
        <option value="4" selected>4th</option>
        <%}else{%>
        <option value="4">4th</option>
        <%}if(strTemp.compareTo("5") ==0)
{%>
        <option value="5" selected>5th</option>
        <%}else{%>
        <option value="5">5th</option>
        <%}if(strTemp.compareTo("6") ==0)
{%>
        <option value="6" selected>6th</option>
        <%}else{%>
        <option value="6">6th</option>
        <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td><select name="c_index">
<%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc", request.getParameter("c_index"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><font size="1" color="#0000FF">Section Name</font></td>
      <td><input type="text" name="section_name" value="<%=WI.fillTextValue("section_name")%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12"></td>
    </tr>
    <tr> 
      <td height="19" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="5%" height="25">&nbsp;</td>
      <td width="95%">Sort by : 
<%
strTemp = WI.fillTextValue("sort_id");
if(strTemp.length() == 0 || strTemp.equals("0")) {
	strErrMsg = " checked";
	strTemp   = "";
}
else {
	strErrMsg = "";
	strTemp   = " checked";
}%>	  <input name="sort_id" type="radio" value="0"<%=strErrMsg%>>Last Name  (asc)
	  <input name="sort_id" type="radio" value="1"<%=strTemp%>>Student ID (asc)</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>
<%
strTemp = WI.fillTextValue("show_data");
if(strTemp.length() == 0 || strTemp.equals("0"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
	  <input name="show_data" type="radio" value="0"<%=strErrMsg%>> Show all data 
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
	  <input name="show_data" type="radio" value="1"<%=strErrMsg%>> Show student with Record 
<%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
	  <input name="show_data" type="radio" value="2"<%=strErrMsg%>> Show student without record 
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><input type="submit" name="1" value="&nbsp;&nbsp;Search&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.print_pg.value='';"></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" style="font-size:9px">
	  <select name="copy_remark" style="font-size:10px; width:400px">
<%
if(bolIsHepa)
	strTemp = " where test_type = 1";
else	
	strTemp = " where test_type = 2";
%>
<%=dbOP.loadCombo("distinct TEST_TYPE","REMARK"," from HM_SACI_HEBAXRAY "+strTemp+" order by remark",null, false)%> 
	  </select> <a href="javascript:CopyRemark()">Copy Remark</a>
	  </td>
      <td width="31%" align="right" style="font-size:9px;"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a> Print report. &nbsp;&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="69%" ><b> Total Students : <%=vRetResult.size()/10%></b></td>
      <td>&nbsp; </td>
    </tr>
  </table>
<%if(bolIsHepa){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="9%" height="25" rowspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Student ID</td>
      <td width="15%" rowspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Student Name</td>
      <td width="30%" rowspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Screening</td>
      <td width="16%" colspan="4" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Dosage</td>
      <td width="25%" rowspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Remarks(max 64 char) </td>
      <td width="5%" rowspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Select<br>
	  <input type="checkbox" name="sel_all" onClick="SelAll();"></td>
    </tr>
    <tr>
      <td align="center" width="4%" style="font-size:9px; font-weight:bold" class="thinborder">1</td>
      <td align="center" width="4%" style="font-size:9px; font-weight:bold" class="thinborder">2</td>
      <td align="center" width="4%" style="font-size:9px; font-weight:bold" class="thinborder">3</td>
      <td align="center" width="4%" style="font-size:9px; font-weight:bold" class="thinborder">Booster</td>
    </tr>
    <%int iRowCount = 0;
for(int i=0; i<vRetResult.size(); i+=10, ++iRowCount){
if(WI.getStrValue(vRetResult.elementAt(i + 4)).equals("1"))
	strTemp = " checked";
else
	strTemp = "";
if(WI.getStrValue(vRetResult.elementAt(i + 5)).equals("1"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
    <tr> 
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><textarea name="screening_<%=iRowCount%>" cols="30" rows="3" class="textbox" style="font-size:9px;" onFocus="SelectBox('<%=iRowCount%>')"><%=WI.getStrValue(vRetResult.elementAt(i + 3))%></textarea></td>
      <td class="thinborder" align="center"><input name="d1<%=iRowCount%>" type="checkbox" value="1" onFocus="SelectBox('<%=iRowCount%>')"<%=strTemp%>></td>
      <td class="thinborder" align="center"><input name="d2<%=iRowCount%>" type="checkbox" value="1" onFocus="SelectBox('<%=iRowCount%>')"<%=strErrMsg%>></td>
<%
if(WI.getStrValue(vRetResult.elementAt(i + 6)).equals("1"))
	strTemp = " checked";
else
	strTemp = "";
if(WI.getStrValue(vRetResult.elementAt(i + 7)).equals("1"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
      <td class="thinborder" align="center"><input name="d3<%=iRowCount%>" type="checkbox" value="1" onFocus="SelectBox('<%=iRowCount%>')"<%=strTemp%>></td>
      <td class="thinborder" align="center"><input name="d4<%=iRowCount%>" type="checkbox" value="1" onFocus="SelectBox('<%=iRowCount%>')"<%=strErrMsg%>></td>
      <td class="thinborder"><textarea name="remark_<%=iRowCount%>" cols="30" rows="3" class="textbox" style="font-size:9px;" onFocus="SelectBox('<%=iRowCount%>')"><%=WI.getStrValue(vRetResult.elementAt(i + 9))%></textarea></td>
      <td class="thinborder" align="center"><input type="checkbox" name="checkbox_<%=iRowCount%>" value="<%=vRetResult.elementAt(i)%>"></td>
    </tr>
    <%}%>
	<input type="hidden" name="max_disp" value="<%=iRowCount%>">
  </table>
<%}else{//xray%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="9%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Student ID</td>
      <td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Student Name</td>
      <td width="30%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Result</td>
      <td width="25%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Remarks(max 64 char) </td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Select<br>
	  <input type="checkbox" name="sel_all" onClick="SelAll();"></td>
    </tr>
    
    <%int iRowCount = 0;
for(int i=0; i<vRetResult.size(); i+=10, ++iRowCount){%>
    <tr> 
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><textarea name="tr_<%=iRowCount%>" cols="30" rows="3" class="textbox" style="font-size:9px;" onFocus="SelectBox('<%=iRowCount%>')"><%=WI.getStrValue(vRetResult.elementAt(i + 8))%></textarea></td>
      <td class="thinborder"><textarea name="remark_<%=iRowCount%>" cols="30" rows="3" class="textbox" style="font-size:9px;" onFocus="SelectBox('<%=iRowCount%>')"><%=WI.getStrValue(vRetResult.elementAt(i + 9))%></textarea></td>
      <td class="thinborder" align="center"><input type="checkbox" name="checkbox_<%=iRowCount%>" value="<%=vRetResult.elementAt(i)%>"></td>
    </tr>
    <%}%>
	<input type="hidden" name="max_disp" value="<%=iRowCount%>">
  </table>
<%}//end of else.. for xray..  %>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
		<td align="center">
<input type="submit" name="1" value="&nbsp;&nbsp;Update Information&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1';document.form_.print_pg.value='';">		
		</td>
	</tr>
  </table>
<%}//end of display. %>
<input type="hidden" name="test_type" value="<%=WI.fillTextValue("test_type")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="print_pg">
<input type="hidden" name="report_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>