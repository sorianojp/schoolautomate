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
	DataMigrate dm   = new DataMigrate();
	String strErrMsg = null;
	String strTemp   = null;
	WebInterface WI  = new WebInterface(request);
	DBOperation dbOP = null;
	
	try {
		dbOP = new DBOperation();		
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening DB Connection.</font></p>
		<%
		return;
	}
//add security here.

CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Data Migrate",request.getRemoteAddr(),
														"migrate_lms.jsp");
	//iAccessLevel = 2;
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	if(WI.fillTextValue("migrate_").compareTo("1") == 0) {
		if(dm.migrateLMSUI(dbOP, request)) {
			if(dm.getErrMsg() != null)
				strErrMsg = dm.getErrMsg();
			else
				strErrMsg = "Migration processed without any error. Please check database using query sample given.";
		}
		else	
			strErrMsg = "Error in migration. Msg :: "+dm.getErrMsg();
	}

%>


<body>
<form name="form_" action="./migrate_lms.jsp" method="post">
<%if(strErrMsg!= null){%><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font><br><br><br><%}%>
  <p><font size="3">NOTE : <br>
    1. Import lms data to school database with table name lms_datamigrate <br>
    2. All fileds below will be migrated. Do not leave any field empty, if there is no filed to migrate, create a filed in lms_datamigrate<br>
    3. To check data migrated, execute this query : select * from lms_datamigrate where is_migrated = 1<br>
	4. To check data not migrated, execute this query : select * from lms_datamigrate where is_migrated is null<br>
	5. lms_datamigrate must not have any column name with space. For example accession Number name in db should be accession_no1 instead of "accession # 1"
</font>
  <br><br>
  <input type="checkbox" name="barcode_" value="checked" <%=WI.fillTextValue("barcode_")%>> Include Barcode Number in Migration.
  Note: Barcode Number must be in format barcode_1, barcode_2 ..... 
  
  </p>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFFFAF"> 
      <td height="25" class="thinborder"><div align="center"><strong>Equivalent field name in  lms_datamigrate</strong></div></td>
      <td class="thinborder"><strong>Field Name in LMS catalog screen </strong></td>
    </tr>
    <tr> 
      <td width="37%" height="25" class="thinborder"> <div align="center"> 
          <textarea name="accession_list" class="textbox" style="font-size:10px" onFocus="style.backgroundColor='#D3EBFF'" rows="4" cols="70"
		  onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("accession_list")%></textarea>
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td width="63%" class="thinborder">Accession No. (if there are more accession Number, put in comma separated value) </td>
    </tr>
    <tr>
      <td height="25" class="thinborder"> <div align="center"> 
          <textarea name="sh_ref" class="textbox" style="font-size:10px" onFocus="style.backgroundColor='#D3EBFF'" rows="4" cols="70"
		  onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("sh_ref")%></textarea>
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">Subject Heading (Tropical Term) Information </td>
    </tr>
    <tr>
      <td height="25" class="thinborder"> <div align="center"> 
          <textarea name="added_entry_ref" class="textbox" style="font-size:10px" onFocus="style.backgroundColor='#D3EBFF'" rows="4" cols="70"
		  onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("added_entry_ref")%></textarea>
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">Added Entry (Author Name) Information </td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="book_title_ref" value="<%=WI.fillTextValue("book_title_ref")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">Book Title </td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="book_subtitle_ref" value="<%=WI.fillTextValue("book_subtitle_ref")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">Book Subtitle </td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="edition_ref" value="<%=WI.fillTextValue("edition_ref")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">Edition</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="isbn_ref" value="<%=WI.fillTextValue("isbn_ref")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">ISBN        </td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="author_ref" value="<%=WI.fillTextValue("author_ref")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">Author Name (last name, first name)</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="publisher_ref" value="<%=WI.fillTextValue("publisher_ref")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">Publisher Name </td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="publisher_place_ref" value="<%=WI.fillTextValue("publisher_place_ref")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">Publisher Place </td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="publisher_yr_ref" value="<%=WI.fillTextValue("publisher_yr_ref")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">Publisher Year </td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="oth_pd_ref" value="<%=WI.fillTextValue("oth_pd_ref")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">Other Physical Description </td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="collection_loc_ref" value="<%=WI.fillTextValue("collection_loc_ref")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">Collection Location </td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="book_loc_ref" value="<%=WI.fillTextValue("book_loc_ref")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">Book Location Name </td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> 
          <input type="text" name="circulation_type_ref" value="<%=WI.fillTextValue("circulation_type_ref")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <font size="3"><font color="#FF0000"><strong>*</strong></font></font></div></td>
      <td class="thinborder">Circulation Type </td>
    </tr>
    <tr>
      <td height="25" class="thinborder" align="center"><input type="text" name="author_code_ref" value="<%=WI.fillTextValue("author_code_ref")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="3"><font color="#FF0000"><strong>*</strong></font></font></td>
      <td class="thinborder">Author Code </td>
    </tr>
    <tr>
      <td height="25" class="thinborder" align="center"><input type="text" name="call_no_ref" value="<%=WI.fillTextValue("call_no_ref")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="3"><font color="#FF0000"><strong>*</strong></font></font></td>
      <td class="thinborder">Call No </td>
    </tr>
    <tr>
      <td height="25" class="thinborder" align="center"><input type="text" name="classification_no_ref" value="<%=WI.fillTextValue("classification_no_ref")%>" size="32" class="textbox" style="font-size:14px"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="3"><font color="#FF0000"><strong>*</strong></font></font></td>
      <td class="thinborder">Classification No </td>
    </tr>
  </table>
<p>
<div align="center"><a href="#"><img src="../../../images/online_help.gif" border="0"></a><font size="1"> 
  Click to view datas not yet migrated&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font> 
  <a href="javascript:Migrate()"><img src="../../../images/move.gif" border="0" name="hide_move"></a><font size="1">Click 
  to move/migrate information</font></div>
</p>
<input type="hidden" name="migrate_">
<input type="hidden" name="show_data">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>