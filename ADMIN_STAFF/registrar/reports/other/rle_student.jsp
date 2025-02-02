<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/td.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintRLE() {
	var pgLoc = "./rle_student_print.jsp?stud_id="+document.form_.stud_id.value+
	"&sy_from="+document.form_.sy_from.value+"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage(){
	document.form_.print_page.value="";
	document.form_.submit();
}

function PrintPage(){
	document.form_.print_page.value="1";
	document.form_.submit();
}

function UpdateGrade(strGSIndex, strGrade) {//alert(" change here. "+strGSIndex);

	//alert("gesINdex : " + strGSIndex);
	//alert("strGrade : " + strGrade);

	if(strGSIndex == '')
		return;
	if(strGrade != '---')
		return;

	var vNewGrade = prompt("Please enter new grade : ","New Grade");
	if(vNewGrade == null)
		return;
	document.form_.gs_index.value = strGSIndex;
	document.form_.new_grade.value = vNewGrade;
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus();">
<%@ page language="java" import="utility.*,enrollment.RLEInformation,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	
	if (WI.fillTextValue("print_page").equals("1")){ %>
		<jsp:forward page="rle_student_print_cgh.jsp" />
<%	}

	String strErrMsg = null;
	String strTemp = null;
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

//add security here.
	try
	{
		dbOP = new DBOperation();
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

enrollment.RLEInformation rle = new enrollment.RLEInformation();
Vector vAffHospitals =null;
Vector vGrades = null;
Vector vClinicExp = null;
Vector vRetResult = null;

if(WI.fillTextValue("gs_index").length() > 0 && WI.fillTextValue("new_grade").length() > 0) {
	try {
		Double.parseDouble(WI.fillTextValue("new_grade"));
		strTemp = "update g_sheet_final set grade = "+WI.fillTextValue("new_grade")+" where gs_index = "+
			WI.fillTextValue("gs_index");
		dbOP.executeUpdateWithTrans(strTemp, null, null, false);		
	}
	catch(Exception e) {strErrMsg = "Please enter grade in correct format.";}
}


if (strSchCode.startsWith("CGH") && WI.fillTextValue("batch_no").length() > 1
	&& WI.fillTextValue("stud_id").length() > 1){

	vRetResult = rle.getStudentAffiliationRecord(dbOP, request);
												
	if (vRetResult == null) 
		strErrMsg = rle.getErrMsg();
	else{
		vClinicExp = (Vector)vRetResult.elementAt(0);
		vGrades = (Vector)vRetResult.elementAt(1);
		vAffHospitals = (Vector)vRetResult.elementAt(2);
	}
}
%>

<form name="form_" action="./rle_student.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: 
        RLE REQUIREMENT PRINT PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" >
	  <a href="./rle_main.jsp"><img src="../../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;
	  <strong style="font-size:14px; color:#FF0000"><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
<% if (!strSchCode.startsWith("CGH")) {%> 
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" style="font-size:11px;">SY/Term</td>
      <td colspan="2" ><%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0) {
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
}
%>
        <input type="text" name="sy_from" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress="AllowOnlyInteger('form_', 'sy_from');"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input type="text" name="sy_to" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
-
<select name="semester">
  <%
strTemp     = WI.fillTextValue("semester");
if(strTemp.length() ==0) {
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
}
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
</select></td>
    </tr>
<%}else{%> 

    <tr>
      <td height="25" >&nbsp;</td> 
      <td height="25" style="font-size:11px;">Batch No </td>
      <td ><%
strTemp = WI.fillTextValue("batch_no");
if(strTemp.length() ==0) {
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
}
%>
	<select name="batch_no">
	<%=dbOP.loadCombo("distinct batch_no", "batch_no", 
					" from rle_batch_set where is_valid = 1 and is_del = 0 order by rle_batch_set.batch_no desc", 
					strTemp,false)%>
	</select>	  </td>
      <td >&nbsp;
	  <%if(strSchCode.startsWith("CGH")){%>
	  	<input name="show_dean" type="checkbox" value="checked" <%=WI.fillTextValue("show_dean")%>> 
	  	Show Dean Name  (OR) <br> 
	  	<input name="show_other_1" type="textbox" value="<%=WI.fillTextValue("show_other_1")%>"> Show Name 
	  	<input name="show_other_2" type="textbox" value="<%=WI.fillTextValue("show_other_2")%>"> Show Designation 
	  <%}%>	  </td>
    </tr>
<%}%> 
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td width="12%" height="25" style="font-size:11px;">Student ID</td>
      <td width="20%" >
	  <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="20" maxlength="32"></td>
      <td width="65%" ><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" border="0"></a>
<% if (strSchCode.startsWith("CGH")) {%> 
	<a href="javascript:ReloadPage()"><img src="../../../../images/form_proceed.gif" border="0"></a>
<%}%>	  </td>
    </tr>
<% if (strSchCode.startsWith("CGH")) {%> 
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="3" style="font-size:11px;">Subjects to Exclude: 
	  <input type="text" name="sub_exclude" value="<%=WI.fillTextValue("sub_exclude")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="100" style="font-size:11px;">
	  <br><font style="font-size:9px; color:#0000FF; font-weight:bold">Note: Please put subject code in comma separated value to remove in printout. 
	  For example: NCM 101 RLE, NCM 100 RLE, etc.</font>	  </td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="3" style="font-size:11px;">Remark: 
      <input type="text" name="remarks_" value="<%=WI.fillTextValue("remarks_")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="100" style="font-size:11px;"></td>
    </tr>
<%} if (!strSchCode.startsWith("CGH")) {%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="3" align="center">
        <input type="button" name="1" value=" Print RLE Summary>>" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PrintRLE();">
      &nbsp;&nbsp;</td>
    </tr>
<%}%> 
    <tr bgcolor="#FFFFFF"><td height="25" >&nbsp;</td><td colspan="3" valign="top">&nbsp;</td>   
	</tr>
  </table>
  
    <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
<%if (vClinicExp != null){%>
    <tr>
      <td colspan="2" height="20">	</td>
	</tr>
    <tr>
      <td colspan="2" height="25">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" id="myADTable4">
	<tr>
	  <td width="30%" class="thinborder"><strong>&nbsp;&nbsp;RLE Focus </strong></td>
      <td width="41%" class="thinborder"><strong>Clinical Area </strong></td>
      <td width="12%" class="thinborder"><div align="center"><strong>No. of <br>
      Weeks </strong></div></td>
      <td width="9%" class="thinborder"><strong>No. of Hours </strong></td>
      <td align="center" class="thinborder"><strong>Grade</strong></td>
	</tr>
<% 	int iIndexOf = 0; int iCount =0;
	for (int i = 0; i < vClinicExp.size() ;  i+= 11, iCount++){
		iIndexOf = vGrades.indexOf(new Integer((String)vClinicExp.elementAt(i+2)));
%> 
	<tr>
	  <td class="thinborderLEFT"><br><strong><%=(String)vClinicExp.elementAt(i+3) + " :: " + 
	  					(String)vClinicExp.elementAt(i+4)%></strong></td>
      <td class="thinborderLEFT">&nbsp;</td>
      <td align="center" class="thinborderLEFT">&nbsp;(<%=WI.getStrValue((String)vClinicExp.elementAt(i+6),"&nbsp;")%> hrs/wk)</td>
      <td class="thinborderLEFT">&nbsp;</td>
      <td width="8%" class="thinborderLEFT">&nbsp;</td>
	</tr>
	<tr >
	  <td valign="top" class="thinborder"><%=WI.getStrValue((String)vClinicExp.elementAt(i+5),"&nbsp;")%><br><br></td>
      <td valign="top" class="thinborder"><%=WI.getStrValue((String)vClinicExp.elementAt(i+7),"&nbsp;")%><br><br></td>
      <td align="center" valign="top" class="thinborder"><%=WI.getStrValue((String)vClinicExp.elementAt(i+8),"&nbsp;")%><br><br></td>
      <td align="center" valign="top" class="thinborder"><%=WI.getStrValue((String)vClinicExp.elementAt(i+10),"&nbsp;")%></td>
	  <td width="8%" class="thinborder" valign="top">&nbsp;
	<% if (iIndexOf != -1){%> 
		<label id="change_grade<%=iCount%>" 
			onDblClick="UpdateGrade('<%=(String)vGrades.elementAt(iIndexOf + 2)%>','<%=WI.getStrValue((String)vGrades.elementAt(iIndexOf + 1),"---")%>');">
					<%=WI.getStrValue((String)vGrades.elementAt(iIndexOf + 1),"---")%>
		</label>
	<% }%>
		
	  </td>
	</tr>
<%}%>  
	 </table>	</td>
  </tr>
	
<%} if (vAffHospitals != null) {%> 
    <tr>
      <td colspan="2" height="18" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2" height="25" ><table width="60%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
	  <td height="20" colspan="2" align="center" class="thinborder" style="font-size:11px; font-weight:bold"><strong>AREAS OF CLINICAL AFFILIATION </strong></td>
	  <td width="23%" class="thinborder" align="center" style="font-size:11px; font-weight:bold">BED CAPACITY </td>
	  </tr>
<%
	String[] astrBaseName = {"Institutions of Affiliation","Base Hospital"};
	String strBaseHospital = "";
	for(int i = 0; i < vAffHospitals.size(); i += 8) {
	  if (!strBaseHospital.equals((String)vAffHospitals.elementAt(i+7))){
	  	strBaseHospital = (String)vAffHospitals.elementAt(i+7);
%>
	<tr>
	  <td height="18" colspan="2" class="thinborderLEFT" style="font-size:11px;"><em>
	  		&nbsp;<%=astrBaseName[Integer.parseInt(strBaseHospital)]%> :	   	</em></td>
      <td height="18" class="thinborderLEFT" style="font-size:11px;">&nbsp;</td>
      </tr>
<% }%> 
	<tr>
	  <td width="10%" height="19" valign="top" class="thinborder" style="font-size:11px;">&nbsp;</td>
	  <td width="67%" class="thinborderBOTTOM" style="font-size:11px;"><span class="thinborderBOTTOM" style="font-size:11px;"><%=vAffHospitals.elementAt(i + 1)%></span></td>
	  <td class="thinborder" style="font-size:9px;" align="center"><%=WI.getStrValue((String)vAffHospitals.elementAt(i + 6),"---")%></td>
	  </tr>
<%}//end of ret result.%>
  </table>  </td>
    </tr>
    <tr>
      <td width="50%" height="44" align="right" valign="bottom" >&nbsp;Subjects per Page : 
	  <select name="rows_per_page">
	  <% 
int iDefPage = 3;
if(strSchCode.startsWith("CGH"))
	iDefPage = 5;	  
	  for (int k = iDefPage; k < 10; k++){%> 
	  	<option value="<%=k%>"><%=k%></option>
	  <%}%> 
	  </select>
	  </td>
      <td width="50%" height="44" valign="bottom" ><a href="javascript:PrintPage()"><img src="../../../../images/print.gif" border="0"></a></td>
      </tr>
<%}%>
  </table>
  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" value="" name="print_page">
<input type="hidden" name="gs_index">
<input type="hidden" name="new_grade">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
