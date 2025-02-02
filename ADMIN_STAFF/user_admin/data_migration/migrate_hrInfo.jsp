<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function Migrate() {
	document.form_.migrate_.value = "1";
	document.form_.hide_move.src = "../../../images/blank.gif";
	document.form_.show_data.value = "";
	this.SubmitOnce('form_');
}
function ShowData() {
	document.form_.migrate_.value = "";
	document.form_.show_data.value = "1";
	this.SubmitOnce('form_');
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DataMigrate dm = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		if (WI.fillTextValue("user_name").length() > 0 && WI.fillTextValue("table_name").length() > 0){
			dm = new DataMigrate(request);
		}
		else {
			strErrMsg = "Please enter all database information.";
		}
	}
	catch(Exception exp)
	{	if(dm != null)
			dm.cleanUP();
		dm = null;
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		//dm.cleanUP();
		return;
	}
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 2;
if(dm != null) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dm.dbOPLiveDB,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Data Migrate",request.getRemoteAddr(),
														"migrate_hrInfo.jsp");
	//iAccessLevel = 2;
	if(iAccessLevel == -1)//for fatal error.
	{
		dm.dbOPLiveDB.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)
	{
		dm.dbOPLiveDB.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	if(WI.fillTextValue("migrate_").compareTo("1") == 0) {
		dm.migrateHROthInfo();
		strErrMsg = dm.getErrMsg();
	}

}
%>


<body>
<form name="form_" action="./migrate_hrInfo.jsp" method="post">
<%if(strErrMsg!= null){%><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font><br><br><br><%}%>
  <p><font size="3">NOTE : To Migrate HR Other Information, first migrate HR Profile<br>
    1. Source of the information below must contain only valid values.<br>
    2. All the date fields in source must be date data type.</font></p>
  <p><font size="3">HR file information other than fields specified below can't 
    be migrated due to data conversion compatibility issues. To migrate repeating 
    values (to migrate more than one vlaues in exam information, etc.), please 
    ask help from support.</font> 
  <p>SB_DataMigrate Database Information : <br>
    Name of Table 
    <input type="text" name="table_name" value="<%=WI.fillTextValue("table_name")%>" size="16" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    ; User name 
    <input type="text" name="user_name" value="<%=WI.fillTextValue("user_name")%>" size="7" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    ; Password 
    <input type="password" name="password" value="<%=WI.fillTextValue("password")%>" size="12" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    <br>
  </p>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFFFAF"> 
      <td height="25" class="thinborder"><div align="center"><strong>FIELD NAME 
          OF SB_DATAMIGRATE TO MIGRATE</strong></div></td>
      <td class="thinborder"><strong>DATA TO MIGRATE</strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" class="thinborder" bgcolor="#0FCFFF"><div align="center"><strong>ADDITIONAL 
          PERSONAL INFORMATION (ONE ENTRY)</strong></div></td>
    </tr>
    <tr> 
      <td width="37%" height="25" class="thinborder"> <div align="center"> 
          <input type="text" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td width="63%" class="thinborder">EMPLOYEE ID</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="civil_stat" value="<%=WI.fillTextValue("civil_stat")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"></font></font></div></td>
      <td class="thinborder">CIVIL STATUS (pls check the civil status in System)</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="pob" value="<%=WI.fillTextValue("pob")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">PLACE OF BIRTH</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="nationality" value="<%=WI.fillTextValue("nationality")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"></font></font></div></td>
      <td class="thinborder">NATIONALITY</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="religion" value="<%=WI.fillTextValue("religion")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">RELIGION</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="sss" value="<%=WI.fillTextValue("sss")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">SSS NUMBER</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="tin" value="<%=WI.fillTextValue("tin")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">TIN</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="philhealth" value="<%=WI.fillTextValue("philhealth")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">PHILHEALTH</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="pag_ibig" value="<%=WI.fillTextValue("pag_ibig")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">PAG-IBIG</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="peraa" value="<%=WI.fillTextValue("peraa")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">PERAA</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="f_name" value="<%=WI.fillTextValue("f_name")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">FATHER'S NAME</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="f_occu" value="<%=WI.fillTextValue("f_occu")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">FATHER'S OCCUPATION</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="m_name" value="<%=WI.fillTextValue("m_name")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">MOTHER'S NAME</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="m_occu" value="<%=WI.fillTextValue("m_occu")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">MOTHER'S OCCUPATION</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" class="thinborder" bgcolor="#0FCFFF"><div align="center"><strong>PERMANENT 
          ADDRESS INFORMATION (ONE ENTRY)</strong></div></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="p_con_name" value="<%=WI.fillTextValue("p_con_name")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">CONTACT NAME</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"> <div align="center"> 
          <input type="text" name="p_str_addr" value="<%=WI.fillTextValue("p_str_addr")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">STREET ADDRESS</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"> <div align="center"> 
          <input type="text" name="p_city" value="<%=WI.fillTextValue("p_city")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">CITY/MUNICIPALITY</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="p_provience" value="<%=WI.fillTextValue("p_provience")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">PROVINCE</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="p_country" value="<%=WI.fillTextValue("p_country")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">COUNTRY</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="p_zip" value="<%=WI.fillTextValue("p_zip")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">ZIP CODE</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="p_con_no" value="<%=WI.fillTextValue("p_con_no")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </div></td>
      <td class="thinborder">CONTACT NOS</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" class="thinborder" bgcolor="#0FCFFF"><div align="center"><strong>EMERGENCY 
          CONTCT ADDRESS INFORMATION (ONE ENTRY)</strong></div></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="e_con_name" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("e_con_name")%>" size="32">
        </div></td>
      <td class="thinborder">CONTACT NAME</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="e_relation" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("e_relation")%>" size="32">
        </div></td>
      <td class="thinborder">RELATION</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="e_cn_mob" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("e_cn_mob")%>" size="32">
        </div></td>
      <td class="thinborder">CONTACT NUMBER (MOBILE)</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="e_cn_home" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("e_cn_home")%>" size="32">
        </div></td>
      <td class="thinborder">CONTACT NUMBER (HOME)</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="e_cn_office" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("e_cn_office")%>" size="32">
        </div></td>
      <td class="thinborder">CONTACT NUMBER (OFFICE)</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="e_cn_addr" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("e_cn_addr")%>" size="32">
        </div></td>
      <td class="thinborder">CONTACT ADDRESS</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" class="thinborder" bgcolor="#0FCFFF"><div align="center"><strong>PREVIOUS 
          EMPLOYMENT INFORMATION (MULTIPLE ENTRIES) =&gt; empid+company name(unique)</strong></div></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="pe_cname" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("pe_cname")%>" size="32">
        </div></td>
      <td class="thinborder">COMPANY NAME</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="pe_caddr" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("pe_caddr")%>" size="32">
        </div></td>
      <td class="thinborder">COMPANY ADDRESS</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="pe_ctel" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("pe_ctel")%>" size="32">
        </div></td>
      <td class="thinborder">PHONE NUMBER</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="pe_cpos" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("pe_cpos")%>" size="32">
        </div></td>
      <td class="thinborder">POSITION</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="pe_cdept" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("pe_cdept")%>" size="32">
        </div></td>
      <td class="thinborder">OFFICE/ DEPT.</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="pe_csal" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("pe_csal")%>" size="32">
        </div></td>
      <td class="thinborder">SALARY</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="pe_cdoe" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("pe_cdoe")%>" size="32">
        </div></td>
      <td class="thinborder">DATE OF EMPLOYMENT</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="pe_cdor" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("pe_cdor")%>" size="32">
        </div></td>
      <td class="thinborder">DATE OF RESIGNATION</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="pe_cres" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("pe_cres")%>" size="32">
        </div></td>
      <td class="thinborder">RESPONSIBILITY/ASSIGNMENT</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="pe_cach" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("pe_cach")%>" size="32">
        </div></td>
      <td class="thinborder">ACHIEVEMENT/AWARDS</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="pe_creason" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("pe_creason")%>" size="32">
        </div></td>
      <td class="thinborder">REASON FOR LEAVING</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" class="thinborder" bgcolor="#0FCFFF"><div align="center"><strong>LICENSE 
          INFORMATION (MULTIPLE ENTRIES NOT ALLOWED)</strong></div></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="lic_name" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("lic_name")%>" size="32">
        </div></td>
      <td class="thinborder">LICENSE NAME</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="lic_no" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("lic_no")%>" size="32">
        </div></td>
      <td class="thinborder">LICENSE NUMBER</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="lic_issue" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("lic_issue")%>" size="32">
        </div></td>
      <td class="thinborder">ISSUE DATE (SOURCE MUST BE DATE FIELD)</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="lic_exp" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("lic_exp")%>" size="32">
        </div></td>
      <td class="thinborder">EXPIRY DATE (SOURCE MUST BE DATE FIELD)</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="lic_pissue" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("lic_pissue")%>" size="32">
        </div></td>
      <td class="thinborder">PLACE ISSUED</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="lic_remark" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("lic_remark")%>" size="32">
        </div></td>
      <td class="thinborder">REMARKS</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" class="thinborder" bgcolor="#0FCFFF"><div align="center"><strong>EXAMS 
          TAKEN INFORMATION (MULTIPLE ENTRIES) =&gt; empid+type of exam+date taken(unique)</strong></div></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="ex_type" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("ex_type")%>" size="32">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">TYPE OF EXAM</td>
    </tr>
    <tr>
      <td height="25" class="thinborder"><div align="center">
          <input name="ex_rating" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("ex_rating")%>" size="32">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">RATING(FLOAT/INT datatype):::: RATING UNIT 
	  <select name="ex_rating_unit">
	  <option value="0">%</option>
<%
strTemp = WI.fillTextValue("ex_rating_unit");
if(strTemp.compareTo("1") == 0) {%>
	  <option value="1" selected>MARKS</option>
<%}else{%>
	  <option value="1">MARKS</option>
<%}if(strTemp.compareTo("2") ==0) {%>
	  <option value="2" selected>POINTS</option>
<%}else{%>
	  <option value="2">POINTS</option>
<%}if(strTemp.compareTo("3") == 0) {%>
	  <option value="3" selected>PERCENTILE</option>
<%}else{%>
	  <option value="3">PERCENTILE</option>
<%}if(strTemp.compareTo("4") == 0) {%>
	  <option value="4" selected>GPA</option>
<%}else{%>
	  <option value="4">GPA</option>
<%}%>
	  </select></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="ex_dateT" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("ex_dateT")%>" size="32">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">DATE TAKEN</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="ex_placeT" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("ex_placeT")%>" size="32">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">PLACE TAKEN</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="ex_remark" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("ex_remark")%>" size="32">
        </div></td>
      <td class="thinborder">REMARK</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" class="thinborder" bgcolor="#0FCFFF"><div align="center"><strong>EXTRA 
          ACTIVITIES INFORMATION (MULTIPLE ENTRIES) =&gt; empid+activity (unique)</strong></div></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="extra_type" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("extra_type")%>" size="32">
        </div></td>
      <td class="thinborder">TYPE OF ACTIVITY</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="extra_proj" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("extra_proj")%>" size="32">
        </div></td>
      <td class="thinborder">NATURE OF ACTIVITY / PROJECT</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="extra_service" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("extra_service")%>" size="32">
        </div></td>
      <td class="thinborder">NATURE OF PARTICIPATION/ SERVICE</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="extra_date" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("extra_date")%>" size="32">
         </div></td>
      <td class="thinborder">DATE</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input name="extra_remark" type="text" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("extra_remark")%>" size="32">
        </div></td>
      <td class="thinborder">REMARKS</td>
    </tr>
  </table>

<p>
<div align="center"><a href="#"><img src="../../../images/online_help.gif" border="0"></a><font size="1"> 
  Click to view data not yet migrated&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font> 
  <a href="javascript:Migrate()"><img src="../../../images/move.gif" border="0" name="hide_move"></a><font size="1">Click 
  to move/migrate information</font></div>
</p>
<input type="hidden" name="migrate_">
<input type="hidden" name="show_data">
</form>
</body>
</html>
<%
if(dm != null) 
	dm.cleanUP();
%>