<%@ page language="java" import="utility.*,lms.LmsUtil,lms.CatalogDDC,lms.CatalogLibCol,java.util.Vector,java.util.Calendar" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/builtin.js"></script>
<script language="JavaScript">

function ReloadDate(){
	var strYear = document.form_.periodic_year.value;
	if(strYear.length == 0 || strYear.length != 4)
		return;
	
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.submit();	
	
}

function EditClicked() {

	if(!document.form_.operation_.checked){
		document.form_.submit();
		return;
	}

	var strAccessionNo = prompt("ENTER ACCESSION NO.");
	if(strAccessionNo.length == 0)
		return;
	document.form_.ACCESSION_NO.value = strAccessionNo;
	//document.form_.page_action.value = "2";
	alert("Edits entries of this book only. Please make necessary changes and click SAVE");
	document.form_.submit();
	
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../../ADMIN_STAFF/HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=700,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PageAction(strAction, strInfoIndex) {
	if(document.form_.periodic_month.value.length == 0 && document.form_.periodic_date.value.length > 0){
		alert("You have specified date. Please select month.");
		return;
	}

	if(strAction == '0') {
		if(strInfoIndex.length == 0){
			alert("Information reference is missing.");
			return;
		}
		
		if(!confirm("Are you sure you want to delete this collection."))
			return;
	}
	if(document.form_.page_action.value.length == 0)
		document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../images/blank.gif";
		
	if(document.form_.operation_.checked){
		document.form_.page_action.value = '2';
		if(strAction == '0')
			document.form_.page_action.value = strAction;
	}
	
	if(strAction == '0')
		document.form_.ACCESSION_NO.value = "";
	
	this.SubmitOnce('form_');
}

function FocusID(){
	document.form_.BOOK_TITLE.focus();
}


function AddOtherInformation() {
	
	var strAccessionNo = document.form_.ACCESSION_NO.value;
	if(strAccessionNo.length == 0){
		alert("Accession Number not found.");
		return;
	}

	var loadPg = "./add_collection_subj_headings.jsp?ACCESSION_NO="+escape(strAccessionNo);
	var win=window.open(loadPg,"myfile",'dependent=yes,width=1000,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<%
	String strErrMsg = null;
	String strTemp   = null;
	String strTempGenCatg = null;
	String strTempSubCatg = null; 
	String strTempSubCatgEntry = null;
	
	String strInfoIndex = WI.fillTextValue("info_index");
	String strPageAction = null;
	boolean bolUseEditVal = false;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-LIBRARY COLLECTION","add_collection_standard.jsp");
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
														"LIB_Cataloging","LIBRARY COLLECTION",request.getRemoteAddr(),
														"add_collection_standard.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
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

	CatalogDDC ctlgDDC       = new CatalogDDC();
	CatalogLibCol ctlgLibCol = new CatalogLibCol();
	LmsUtil lUtil            = new LmsUtil();
	String strAccessionNo    = WI.fillTextValue("ACCESSION_NO");
	Vector vEditInfo  = null;boolean bolOpSuccess = true;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(ctlgLibCol.operateOnBasicEntry(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = ctlgLibCol.getErrMsg();
		else {
			bolOpSuccess = true;
			if(strTemp.equals("0"))
				strErrMsg = "Collection entry information successfully deleted.";
			else if(strTemp.compareTo("1") == 0) {
				strErrMsg = "Collection entry information successfully added.";
				//on success, i have to add entry in LMS_BOOK_STAT
				if(strAccessionNo.length() == 0)
					strAccessionNo = ctlgLibCol.getAccessionNo();
				strTemp = dbOP.mapBookIDToBookIndex(strAccessionNo);
				if(strTemp != null){
					dbOP.executeUpdateWithTrans("insert into LMS_BOOK_STAT (BOOK_INDEX,BS_REF_INDEX,"+
						"SY_FROM,SY_TO,SEMESTER,BOOK_STAT_UPDATED) values ("+strTemp+
						",1,"+(String)request.getSession(false).getAttribute("cur_sch_yr_from")+
						","+(String)request.getSession(false).getAttribute("cur_sch_yr_to")+
						","+(String)request.getSession(false).getAttribute("cur_sem")+
						",'"+WI.getTodaysDate()+"')",null,null,false);
					
					//I need to update the book_index of lms_acq_setup_dtls to detemine that the book is in cataloguing						
					if(WI.fillTextValue("setup_details_index").length() > 0)					
						dbOP.executeUpdateWithTrans("UPDATE lms_acq_setup_dtls SET book_index="+strTemp+
							" WHERE setup_dtls_index="+WI.fillTextValue("setup_details_index"),null,null,false);
				}
			}
			else if(strTemp.compareTo("2") == 0 || WI.fillTextValue("operation_").compareTo("2") == 0)
				strErrMsg = "Collection entry information successfully edited.";
			else if(strTemp.compareTo("5") == 0) {
				strErrMsg = "Collection information successfully duplicated.";
				strTemp = dbOP.mapBookIDToBookIndex(WI.fillTextValue("ACCESSION_NO"));
				dbOP.forceAutoCommitToTrue();
				if(strTemp != null)
					dbOP.executeUpdateWithTrans("insert into LMS_BOOK_STAT (BOOK_INDEX,BS_REF_INDEX,"+
						"SY_FROM,SY_TO,SEMESTER,BOOK_STAT_UPDATED) values ("+strTemp+
						",1,"+(String)request.getSession(false).getAttribute("cur_sch_yr_from")+
						","+(String)request.getSession(false).getAttribute("cur_sch_yr_to")+
						","+(String)request.getSession(false).getAttribute("cur_sem")+
						",'"+WI.getTodaysDate()+"')",null,null,false);
			
			}
			else if(strTemp.compareTo("6") == 0) 
				strErrMsg = "All copies of collection information successfully edited.";
				
		}
	}

	
//get vEditInfoIf it is called.
if(WI.fillTextValue("ACCESSION_NO").length() > 0 || WI.fillTextValue("barcode_no").length() > 0) {
	vEditInfo = ctlgLibCol.operateOnBasicEntry(dbOP, request,3);
	if(vEditInfo == null && strErrMsg == null)
		strErrMsg = ctlgLibCol.getErrMsg();
	if(vEditInfo != null && vEditInfo.size() > 0) 
		strInfoIndex = (String)vEditInfo.elementAt(0);
}

if(strInfoIndex == null || strInfoIndex.length() == 0){
	strInfoIndex = ctlgLibCol.getBookIndex();	
}

if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reload_main").length() > 0)
	bolUseEditVal = true;


String strBookStatus = null;

if(vEditInfo != null && vEditInfo.size() > 0) {
	strBookStatus = dbOP.mapOneToOther("LMS_BOOK_STAT","BOOK_INDEX",(String)vEditInfo.elementAt(0), "BS_REF_INDEX",null);
}

String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsUB = strSchCode.startsWith("UB");	
boolean bolIsCIT = strSchCode.startsWith("CIT");

%>


<body bgcolor="#F2DFD2" onLoad="FocusID();">
<form action="./add_collection_standard_periodicals.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="2" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING - LIBRARY COLLECTION - ADD TITLE PAGE ::::</strong></font></div></td>
    </tr>
      <tr> 
      <td width="8%" height="30"><a href="add_collection_standard.jsp" target="_self"><img src="../../images/go_back_rec.gif" width="54" height="29" border="0"></a></td>
      <td width="92%">
	  	<font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font>
	  </td>
      </tr>
  </table>
  
  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="30" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <font color="#FF0000"><strong>NOTE : * Fields must not be empty.</strong></font></td>
    </tr>
	
    <tr>
        <td height="30">&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("operation_");
		if(strTemp.equals("2"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
        <td height="30" colspan="2"><input type="checkbox" name="operation_" value="2" <%=strErrMsg%> onClick="EditClicked();">
			Edit copy
		</td>
    </tr>
	
    <tr bgcolor="#DDDDEE"> 
      <td height="20" colspan="3" class="thinborderALL"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PERIODICAL INFORMATION : </font></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">Title of Periodical<font color="#FF0000">*</font></td>
	  <%
	  strTemp = WI.fillTextValue("BOOK_TITLE");
	  if(vEditInfo != null && vEditInfo.size() > 0)
	  	strTemp = (String)vEditInfo.elementAt(1);
	  %>
      <td width="79%"><input type="text" name="BOOK_TITLE" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="64" maxlength="512"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Title of the Article<font color="#FF0000">*</font></td>
	  <%
	  strTemp = WI.fillTextValue("BOOK_SUB_TITLE");
	  if(vEditInfo != null && vEditInfo.size() > 0)
	  	strTemp = (String)vEditInfo.elementAt(2);
	  %>
      <td><input type="text" name="BOOK_SUB_TITLE" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="64" maxlength="512"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Author of the Article<font color="#FF0000">*</font></td>
	  <%
	  strTemp = WI.fillTextValue("AUTHOR_NAME");
	  if(vEditInfo != null && vEditInfo.size() > 0)
	  	strTemp = (String)vEditInfo.elementAt(11);
	  %>
      <td>
	  	<input type="text" name="AUTHOR_NAME" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
    </tr>
	
	<tr> 
      <td height="28">&nbsp;</td>
      <td valign="top">Physical Description<font color="#FF0000">*</font></td>
	  <%
	  strTemp = WI.fillTextValue("PD_OTH_DESC");
	  if(vEditInfo != null && vEditInfo.size() > 0)
	  	strTemp = (String)vEditInfo.elementAt(21);
	  %>
      <td><textarea name="PD_OTH_DESC" cols="60" rows="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
	
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Year / Month / Date<font color="#FF0000">*</font></td>
      <%
		Calendar cal = Calendar.getInstance();
		int iYear = cal.get(Calendar.YEAR);	
		  
		if(WI.fillTextValue("periodic_year").length() > 0){
			strTemp = WI.fillTextValue("periodic_year");
			iYear = Integer.parseInt(strTemp);
		}else
			strTemp = Integer.toString(iYear);
	  
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(52);
	  
	  %>
	  <td>	  
	<input type="text" name="periodic_year" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','periodic_year');ReloadDate();style.backgroundColor='white';" 
					onkeyup="AllowOnlyInteger('form_','periodic_year')" size="3" maxlength="4" value="<%=strTemp%>" />
	  
	  /
	  <select name="periodic_month" style="width:100px;" onChange="ReloadDate();">
	  		<option value=""></option>
	  <%
		int iMonth = cal.get(Calendar.MONTH);
		if(WI.fillTextValue("periodic_month").length() > 0)			
			iMonth = Integer.parseInt(WI.fillTextValue("periodic_month"));	
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(50);
			if(strTemp != null && strTemp.length() > 0)
				iMonth = Integer.parseInt(strTemp);
		}	
	  %>
	  	<%=dbOP.loadComboMonth(Integer.toString(iMonth))%>
	  </select>
	  /
	  <select name="periodic_date" style="width:40px;" onChange="">
	  	<option value=""></option>
	  	<%
		int iDate = cal.get(Calendar.DAY_OF_MONTH);		
		if(WI.fillTextValue("periodic_date").length() > 0)			
			iDate = Integer.parseInt(WI.fillTextValue("periodic_date"));
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(51);
			if(strTemp != null && strTemp.length() > 0)
				iDate = Integer.parseInt(strTemp);
		}			
		%>
	  	<%=CommonUtilExtn.loadMonthDate(iMonth, iYear, iDate)%>
	  </select>	  </td>
    </tr>
<%if(strAccessionNo != null && strAccessionNo.length() > 0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Subject of the Article<font color="#FF0000">*</font></td>
	  <%
	  strTemp = WI.fillTextValue("subject_of_article_index");
	  if(vEditInfo != null && vEditInfo.size() > 0)
	  	strTemp = (String)vEditInfo.elementAt(54);
	  %>
      <td>
	  <a href="javascript:AddOtherInformation();"><img src="../../../images/update.gif" border="0"></a>
	  <font size="1">Click to update subject of the article list</font>
	  <!--<select name="subject_of_article_index" style="font-family:Verdana, Arial, Helvetica, sans-serif; width:300px;">
          <option value="">Select Subject of the Article</option>
		  <%=dbOP.loadCombo("distinct subject_of_article","subject_of_article",
		  	" from lms_lc_main where is_valid =1 order by subject_of_article", strTemp, false)%> </select>
	  <input type="text" name="subject_of_article" value="<%=WI.fillTextValue("subject_of_article")%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="40" maxlength="512">-->
		
		
		</td>
    </tr>
<%}%>
  </table>
  
  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDEE"> 
      <td height="20" colspan="3" class="thinborderALL"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LOCATION/CLASSIFICATION 
        DATA/CIRCULATION TYPE: </font></td>
    </tr>
    <tr> 
      <td width="3%" height="28">&nbsp;</td>
      <td height="28">Collection Location<font color="#FF0000">*</font></td>
      <td height="28"> 
<%
	strTemp = WI.fillTextValue("LOC_INDEX");
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(22); 
%> <select name="LOC_INDEX"
	  style="font-family:Verdana, Arial, Helvetica, sans-serif; width:300px;">
          <%=dbOP.loadCombo("LOC_INDEX","LOC_NAME"," from LMS_LIBRARY_LOC order by LOC_NAME asc",
		  	strTemp, false)%> </select> <font size="1" ><a href='javascript:viewList("LMS_LIBRARY_LOC","LOC_INDEX","LOC_NAME","LOCATION","LMS_LC_MAIN","LOC_INDEX", 
				" and LMS_LC_MAIN.IS_VALID=1","","LOC_INDEX");'><img src="../../images/update_rec.gif" border="0" align="absmiddle"></a></font></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td width="23%" height="28">Book Location Name<font color="#FF0000">*</font></td>
      <td height="28"> 
<%
	strTemp = WI.fillTextValue("BOOK_LOC_INDEX");
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(23);
%> <select name="BOOK_LOC_INDEX"
	  style="font-family:Verdana, Arial, Helvetica, sans-serif; width:300px;">
          <%=dbOP.loadCombo("BOOK_LOC_INDEX","LOCATION"," from LMS_BOOK_LOC order by LOCATION asc",
		  	strTemp, false)%> </select> <font size="1" ><a href='javascript:viewList("LMS_BOOK_LOC","BOOK_LOC_INDEX","LOCATION","BOOK_LOCATION","LMS_LC_MAIN","BOOK_LOC_INDEX", 
				" and LMS_LC_MAIN.IS_VALID = 1","","BOOK_LOC_INDEX");'><img src="../../images/update_rec.gif" border="0" align="absmiddle"></a></font></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Circulation Type<font color="#FF0000">*</font></td>
      <td height="28"> 
<%
	strTemp = WI.fillTextValue("CTYPE_INDEX");
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(24); 
%> <select name="CTYPE_INDEX"
	  	  style="font-family:Verdana, Arial, Helvetica, sans-serif; width:300px;">
          <%=dbOP.loadCombo("CTYPE_INDEX","DESCRIPTION"," from LMS_CLOG_CTYPE WHERE IS_VALID = 1 AND IS_DEL = 0 order by DESCRIPTION asc",
		  	strTemp, false)%> </select></td>
    </tr>
   
    <tr> 
      <td height="15">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <%
if(iAccessLevel > 1){%>
    <tr> 
      <td height="42" colspan="6" class="thinborderBOTTOM"><div align="center"><font size="1"></font> <font size="1"></font>
          <font size="1"><a href='javascript:PageAction(1,"");'> <img src="../../images/save_recommend.gif" border="0" name="hide_save"></a> 
          Click to save entries <a href="./add_collection_standard_periodicals.jsp"><img src="../../../images/clear.gif" border="1"></a> 
          Clear entries 
          <%
		  if(strInfoIndex != null && strInfoIndex.length() > 0)
			if(strBookStatus != null && strBookStatus.compareTo("2") == 0) {%>
          Book is issued,delete not allowed. 
          <%}else{%>
          <a href="javascript:PageAction(0,'<%=WI.getStrValue(strInfoIndex)%>');"><img src="../../../images/delete.gif" border="1"></a> 
          Delete Collection information 
          <%}%>
          </font></div></td>
    </tr>
    <%}%>
    
  </table>
  
  
<input type="hidden" name="info_index" value="<%=WI.getStrValue(strInfoIndex)%>">
<input type="hidden" name="page_action">
<input type="hidden" name="reload_main">
<input type="hidden" name="focus_id_page_no">
<input type="hidden" name="setup_details_index" value="<%=WI.fillTextValue("setup_details_index")%>" >

<input type="hidden" name="is_periodicals" value="1">
<input type="hidden" name="ACCESSION_NO" value="<%=WI.getStrValue(strAccessionNo)%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>