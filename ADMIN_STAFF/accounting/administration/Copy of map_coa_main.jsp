<%@ page language="java" import="utility.*" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
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
	if(WI.fillTextValue("update_map").length() > 0) {
		strTemp = "select prop_val from read_property_file where prop_name = 'AR_MAPPING_PERCOLLEGE'";
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp == null) 
			strTemp = "insert into read_property_file (prop_name, prop_val, is_higher_edu) values ('AR_MAPPING_PERCOLLEGE',"+WI.fillTextValue("mapping_ref")+",1) ";
		else	
			strTemp = "update read_property_file set prop_val = '"+WI.fillTextValue("mapping_ref")+"' where prop_name = 'AR_MAPPING_PERCOLLEGE'";
		dbOP.executeUpdateWithTrans(strTemp, null, null, false);
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css" />
</head>
<script language="JavaScript">
function PrintEnrollmentForm() {
	var studID = prompt("Please enter Student's ID.", "Temp/ perm ID.");
	if(studID.length == 0)  {
		alert("Failed to process request. Stud. ID is empty.");
		return;
	}	
	var pgLoc = "./entrance_admission_slip_new_print.jsp?temp_id="+studID;
	var win=window.open(pgLoc,"AdmissionSlip",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function EditTempStudGSPIS() {
	var strTempID = prompt("Please enter temporary student ID .:");
	if(strTempID == "" || strTempID == null) {
		alert("Temp Id can't be empty.");
		return ;
	}
	var strLoc = "../../../PARENTS_STUDENTS/ADMISSION MODULE PAGES/single file items/ADMISSION FOR NEW_TRANSFERRE STUDENTS/gspis_page_edit_temp.jsp";
	location = escape(strLoc)+"?temp_id="+strTempID;
}
</script>
<body bgcolor="#D2AE72">
<form action="./map_coa_main.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A" align="center">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div><font color="#FFFFFF" ><strong>:::: 
        MAPPING OF CHART OF ACCOUNTS ::::</strong></font></div></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
<%
strTemp = "select prop_val from read_property_file where prop_name = 'AR_MAPPING_PERCOLLEGE'";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp != null) {
	if(strTemp.equals("0"))
		strTemp = "PER COURSE";
	else	
		strTemp = "PER COLLEGE";
}
%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2">Mapping is applied : 
	<%if(strTemp != null){%> <b><%=strTemp%></b>
	<%}else{%>
		<select name="mapping_ref" onChange="document.form_.update_map.value='1';document.form_.submit();">
			<Option value=""></Option>
			<Option value="0">PER COURSE</Option>
			<option value="1">PER COLLEGE</option>
		</select>
	<%}%>
	</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td colspan="2"><strong>Map AR Tuition</strong> </td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./map_coa_college.jsp?is_debit=1">Debit</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./map_coa_college.jsp?is_debit=0">Credit</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td colspan="2"><strong>Map Scholarship/Discounts</strong> </td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./map/map_scholarship.jsp?is_debit=1">Debit</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./map/map_scholarship.jsp?is_debit=0">Credit</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td colspan="2"><strong>Map Miscellaneous Fee </strong> </td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./map/map_scholarship.jsp?is_debit=1">Debit</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./map/map_scholarship.jsp?is_debit=0">Credit</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td colspan="2"><strong>Map Other Charges (Lab Fee/Hands On) </strong> </td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./map/map_scholarship.jsp?is_debit=1">Debit</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./map/map_scholarship.jsp?is_debit=0">Credit</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td colspan="2"><strong>Map Other School Fee (Tuition Fee Type) </strong></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./map/map_scholarship.jsp?is_debit=1">Debit</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./map/map_scholarship.jsp?is_debit=0">Credit</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td colspan="2"><strong>Map Other School Fee (Non-Tuition Fee Type)</strong> </td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./map/map_scholarship.jsp?is_debit=1">Debit</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./map/map_scholarship.jsp?is_debit=0">Credit</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td colspan="2"><strong>Map Cash Receipts </strong> </td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./map/map_scholarship.jsp?is_debit=1">Debit</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./map/map_scholarship.jsp?is_debit=0">Credit</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td width="7%" height="25">&nbsp;</td>
    <td width="1%">&nbsp;</td>
    <td width="82%"><div align="left"><a href="./chart_of_accounts/fm_map_coa_oth_sch_fee.jsp?misc=1">Link Miscellaneous charges - Required for enrollment AR </a></div></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./chart_of_accounts/fm_map_coa_oth_sch_fee.jsp?misc=0">Link Other charges - Required for enrollment AR </a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./chart_of_accounts/fm_map_coa_oth_sch_fee.jsp?misc=2">Link Other School Fees - Required for Other school fee collection</a></td>
  </tr>
  <tr>
    <td colspan="3"><hr size="1"></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td width="82%">&nbsp;</td>
  </tr>
  <tr> 
    <td width="7%" height="24">&nbsp;</td>
    <td width="1%">&nbsp;</td>
    <td width="82%">&nbsp;</td>
  </tr>
  <tr>
    <td height="24">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="24">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr bgcolor="#A49A6A"> 
    <td width="149%" height="25">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="update_map">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>