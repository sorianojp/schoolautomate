<%@ page language="java" import="utility.*,lms.LmsUtil,lms.CatalogDDC,lms.CatalogLibCol,java.util.Vector" %>
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
<link href="../../css/treelinkcss.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/builtin.js"></script>
<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm("Are you sure you want to delete this collection."))
			return;
	}
	if(document.form_.page_action.value.length == 0)
		document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}

function GetBookFromAcquisition(){
	loadPg = "../../search/search_acquisition_book.jsp?ctlg_search=1";
		var win=window.open(loadPg,"myfile",'dependent=yes,width=700,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPageGC() {
	document.form_.focus_id_page_no.value = "3";

	document.form_.page_action.value = "";
	document.form_.SUB_CATG_INDEX.selectedIndex =0;
	document.form_.SUB_CATG_ENTRY_INDEX.selectedIndex =0;
	this.SubmitOnce('form_');
}
function ReloadPageSC() {
	document.form_.focus_id_page_no.value = "3";

	document.form_.page_action.value = "";
	document.form_.SUB_CATG_ENTRY_INDEX.selectedIndex =0;
	this.SubmitOnce('form_');
}
function ReloadPageSCE() {
	document.form_.focus_id_page_no.value = "3";

	document.form_.page_action.value = "";
	document.form_.SCE_CLASS_INDEX.selectedIndex =0;
	this.SubmitOnce('form_');
}
//for LC
function ReloadPageLC() {
	document.form_.focus_id_page_no.value = "3";

	document.form_.page_action.value = "";
	document.form_.lc_sc_index.selectedIndex =0;
	document.form_.lc_sce_index.selectedIndex =0;
	this.SubmitOnce('form_');
}
function ReloadPageLCSC() {
	document.form_.focus_id_page_no.value = "3";

	document.form_.page_action.value = "";
	document.form_.lc_sce_class_index.selectedIndex =0;
	this.SubmitOnce('form_');
}
function ReloadPageLCSCE() {
	document.form_.focus_id_page_no.value = "3";

	document.form_.page_action.value = "";
	document.form_.lc_sce_class_index.selectedIndex =0;
	this.SubmitOnce('form_');
}



function ReloadPage() {
	document.form_.focus_id_page_no.value = "2";

	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function ReloadPageMain() {
	document.form_.page_action.value = "";
	document.form_.reload_main.value = "1";
	this.SubmitOnce('form_');
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../../ADMIN_STAFF/HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=700,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	var pageNo = <%=WI.getStrValue(WI.fillTextValue("focus_id_page_no"),"0")%>
	if(pageNo == 0)
		document.form_.ACCESSION_NO.focus();
	else {
		eval('document.form_.pageno_'+pageNo+'.focus()');
	}
}
function AuthCode() {
	var loadPg = "../ac/ac.jsp?search_only=1&opner_info=form_.AUTHOR_CODE";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function AddOtherInformation(pageID) {
	var loadPg;
	strAccessionNo = document.form_.ACCESSION_NO.value;
	if(strAccessionNo.length == 0) 
	{
	alert("Please enter Accession Number.");
		return;
	}
	if(pageID == "1")
		loadPg = "./add_collection_added_desc.jsp?ACCESSION_NO="+escape(strAccessionNo);
	else if(pageID == "2") 
		loadPg = "./add_collection_subj_headings.jsp?ACCESSION_NO="+escape(strAccessionNo);
	else if(pageID == "3") 
		loadPg = "./add_collection_added_entries.jsp?ACCESSION_NO="+escape(strAccessionNo);
	else if(pageID == "4") 
		loadPg = "./add_collection_other_entries.jsp?ACCESSION_NO="+escape(strAccessionNo);
		
	var win=window.open(loadPg,"myfile",'dependent=yes,width=1000,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function DuplicateClicked() {
	document.form_.page_action.value = "5";
	document.form_.ACCESSION_NO.select();
	alert("Duplicates all entries of this book to new book. Please change Book accession number and barcode number and click SAVE.");
	document.form_.barcode_no.select();
}
function EditAllClicked() {
	document.form_.page_action.value = "6";
	alert("Edits entries of all copies. Changing Book accession number is not allowed. Please make necessary changes and click SAVE");
}
function EditClicked() {
	document.form_.page_action.value = "2";
	alert("Edits entries of this book only. Please make necessary changes and click SAVE");
}
function ViewCopy(strBookIndex) {
	location = "./copy_information_view.jsp?copy_info_index="+strBookIndex;
}
function OpenSearch() {
	var pgLoc = "../../search/search_simple.jsp?opner_info=form_.ACCESSION_NO&opner_info2=form_.reload_main&opner_info2_val=1";
	var win=window.open(pgLoc,"PrintWindow",'width=950,height=650,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function AddSubjectForBook(){
	strAccessionNo = document.form_.ACCESSION_NO.value;
	if(strAccessionNo.length == 0) 
	{
	alert("Please enter Accession Number.");
		return;
	}
	var win=window.open("./add_collection_sub.jsp?accession_number="+escape(strAccessionNo),
		"myfile",'dependent=yes,width=1000,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//Call number = classfication number author code, copyright year.
function generateCallNo() {
	var strCallNo = "";
	
	var strTemp = document.form_.AUTHOR_CODE.value;
	var classNo = document.form_.CLASSIFICATION_NO.value;
	var pubDate =  document.form_.PUBLISHER_DATE.value;
	
	if(classNo != "") 
		strCallNo = classNo;
	if(strTemp != "")
		strCallNo = strCallNo + " " + strTemp;
	if(pubDate != ""){
	//	for(var i=pubDate.length;i>0;i++){
		strCallNo = strCallNo + " " + pubDate;
		}
		
	
	/*var strTemp = document.form_.AUTHOR_CODE.value;
	if(strTemp != "") 
		strCallNo = strTemp;
	strTemp = document.form_.CLASSIFICATION_NO.value;
	if(strTemp != "") 
		strCallNo = strCallNo + " " +strTemp;
	strTemp = document.form_.PUBLISHER_DATE.value;
	//if(strTemp.indexOf("c") > -1 || strTemp.indexOf("C") > -1)
		strCallNo = strCallNo + " " +strTemp;
	//else if(strTemp != "")
	//		strCallNo = strCallNo + " " +strTemp+" c";*/
		
	document.form_.CALL_NUMBER.value = strCallNo;
}

function UpdateMaterialType(){	
	strAccessionNo = document.form_.ACCESSION_NO.value;
	loadPg = "./add_material_type.jsp";
		
	var win=window.open(loadPg,"myfile",'dependent=yes,width=1000,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	
}

function UpdateMaterialTypePD(){	
	strAccessionNo = document.form_.ACCESSION_NO.value;
	loadPg = "./add_material_type_pd.jsp?ACCESSION_NO="+escape(strAccessionNo);
		
	var win=window.open(loadPg,"myfile",'dependent=yes,width=1000,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	
}
</script>

<%
	String strErrMsg = null;
	String strTemp   = null;String strTempGenCatg = null;String strTempSubCatg = null; String strTempSubCatgEntry = null;
	
	String strInfoIndex = null;
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
	
	Vector vEditInfo  = null;boolean bolOpSuccess = true;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(ctlgLibCol.operateOnBasicEntry(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = ctlgLibCol.getErrMsg();
		else {
			bolOpSuccess = true;
			if(strTemp.compareTo("1") == 0) {
				strErrMsg = "Collection entry information successfully added.";
				//on success, i have to add entry in LMS_BOOK_STAT
				strTemp = dbOP.mapBookIDToBookIndex(WI.fillTextValue("ACCESSION_NO"));
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



if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reload_main").length() > 0)
	bolUseEditVal = true;

//I have to get here number of copies.
Vector vNoOfCopies = null; int iNoOfCopy = 0;
if(vEditInfo != null && vEditInfo.size() > 0) {
	vNoOfCopies = lUtil.getNoOfCopy(dbOP, (String)vEditInfo.elementAt(0));
	if(vNoOfCopies == null) 
		strErrMsg = lUtil.getErrMsg();
	else	
		iNoOfCopy = vNoOfCopies.size();
}
//iNoOfCopy = 2;
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
<form action="./add_collection_standard.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING - LIBRARY COLLECTION - ADD TITLE PAGE ::::</strong></font></div></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="30" colspan="6"><a href="lib_main.htm" target="_self"><img src="../../images/go_back_rec.gif" width="54" height="29" border="0"></a>&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td height="30" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <font color="#FF0000"><strong>NOTE : * Fields must not be empty.</strong></font></td>
    </tr>
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(48);
else
	strTemp = WI.fillTextValue("ACCESSION_NO");

if(bolIsUB){
%>
    <tr valign="bottom">
        <td height="22">&nbsp;</td>
        <td colspan="5"><a href="./add_collection_standard_periodicals.jsp"><font color="#FF0000"><strong>Click to encode Periodicals</strong></font></a></td>
   </tr>
 <%}%>
    <tr valign="bottom"> 
      <td width="3%" height="41">&nbsp;</td>
      <td width="18%" height="41">Book Accession No.<font color="#FF0000"><strong>*</strong></font></td>
      <td width="27%"> <input type="text" name="ACCESSION_NO" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="20" maxlength="32"> </td>
      <td width="9%">
	  <a href="javascript:OpenSearch();"><img src="../../images/search_recommend.gif" border="1"></a></td>
      <td width="10%">
	  <a href="javascript:ReloadPageMain()"><img src="../../images/form_proceed.gif" border="0"></a></td>
	  <td width="33%">
	  <a href="javascript:GetBookFromAcquisition()"><img src="../../images/show_list.gif" border="0"></a><font size="1">Click to get book data newly acquired</font></td>
    </tr>
    <%
if(vEditInfo != null){%>
    <tr valign="bottom"> 
      <td height="27">&nbsp;</td>
      <td height="27">&nbsp;</td>
      <td colspan="4"> <%
strTemp = WI.fillTextValue("operation_");
//if(strTemp.compareTo("5") == 0) 
//	strTemp = " checked";
//else	
	strTemp = "";
//if(bolOpSuccess)
//	strTemp = "";
%> <input type="radio" name="operation_" value="5" <%=WI.getStrValue(strTemp)%> onClick="DuplicateClicked();">
        Duplicate 
        <%
strTemp = WI.fillTextValue("operation_");
//if(strTemp.compareTo("2") == 0) 
//	strTemp = " checked";
//else	
	strTemp = "";
if(bolOpSuccess)
	strTemp = "";
%> <input type="radio" name="operation_" value="2" <%=WI.getStrValue(strTemp)%> onClick="EditClicked();">
        Edit copy 
        <%
strTemp = WI.fillTextValue("operation_");
//if(strTemp.compareTo("6") == 0) 
//	strTemp = " checked";
//else	
//	strTemp = "";
//if(bolOpSuccess)
	strTemp = "";
if(iNoOfCopy > 1) {%> <input type="radio" name="operation_" value="6" <%=WI.getStrValue(strTemp)%> onClick="EditAllClicked();">
        Edit all copies
<%}%>		</td>
    </tr>
    <tr valign="bottom"> 
      <td height="27">&nbsp;</td>
      <td height="27" class="thinborderALL"><font size="3">No. of Copies : <strong><font color="#FF0000"><%=iNoOfCopy%></font></strong></font></td>
      <td colspan="4">
<%
if(iNoOfCopy > 0) {%>
	  <a href="javascript:ViewCopy(<%=(String)vEditInfo.elementAt(0)%>)"><img src="../../images/view_recommend.gif" border="0"></a> <font size="1">click to open COPY INFORMATION</font>
<%}%>	  </td>
    </tr>
    <%}//show only if vEditInfo is not null %>
    <tr> 
      <td height="10" colspan="6">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="42">&nbsp;&nbsp;</td>
      <td height="42" valign="top">Barcode Number<font color="#FF0000"><strong>*</strong></font></td>
      <td height="42" valign="top"> <%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(36);
else {
	strTemp = request.getParameter("barcode_no");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(36); 
}
%> <input type="text" name="barcode_no" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="32">
        (in case no barcode, use accession no. for barcode)</td>
    </tr>
    <tr bgcolor="#DDDDEE"> 
      <td height="20" colspan="3" class="thinborderALL"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TITLE 
        STATEMENT : </font></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">Title<font color="#FF0000">*</font></td>
      <td width="79%"> <%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(1);
else {
	strTemp = request.getParameter("BOOK_TITLE");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(1); 
}
%> <input type="text" name="BOOK_TITLE" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="64" maxlength="512"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Subtitle</td>
      <td> <%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(2);
else {
	strTemp = request.getParameter("BOOK_SUB_TITLE");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(2); 
}
%> <input type="text" name="BOOK_SUB_TITLE" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="64" maxlength="512"> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Parallel Title</td>
      <td>
        <%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(47);
else {
	strTemp = request.getParameter("BOOK_PARALLEL_TITLE");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(47); 
}
%>
        <input type="text" name="BOOK_PARALLEL_TITLE" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="64" maxlength="512"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Responsibility</td>
      <td> <%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(3);
else {
	strTemp = request.getParameter("RESPONSIBILITY");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(3); 
}
%> <input type="text" name="RESPONSIBILITY" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="64" maxlength="512"></td>
    </tr>
	
	<%if(!bolIsCIT){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Version</td>
      <td> <%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(4);
else {
	strTemp = request.getParameter("BOOK_VERSION");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(4); 
}
%> <input type="text" name="BOOK_VERSION" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
    </tr>
	<%}%>
	
	
    <tr bgcolor="#DDDDEE"> 
      <td height="20" colspan="3" class="thinborderALL"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;EDITION 
        STATEMENT : </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Edition</td>
      <td> <%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(5);
else {
	strTemp = request.getParameter("BOOK_EDTION");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(5); 
}
%> <input type="text" name="BOOK_EDTION" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="32"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Sub-edition</td>
      <td> <%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(6);
else {
	strTemp = request.getParameter("SUB_EDITION");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(6); 
}
%> <input type="text" name="SUB_EDITION" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="32"></td>
    </tr>
	
	<%if(bolIsCIT){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Version</td>
      <td> 
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(4);
else {
	strTemp = request.getParameter("BOOK_VERSION");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(4); 
}
%> <input type="text" name="BOOK_VERSION" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="512"></td>
    </tr>
	
	
	<tr bgcolor="#DDDDEE"> 
      <td height="20" colspan="3" class="thinborderALL"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;MATHEMATICAL DATA AREA : </font></td>
    </tr>
	<tr> 
      <td height="25">&nbsp;</td>
      <td>Scale Info</td>
      <td> 
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(49);
else {
	strTemp = request.getParameter("scale_info");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(49); 
}
%> <input type="text" name="scale_info" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
    </tr>
	<%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDEE"> 
      <td height="20" colspan="7" class="thinborderALL"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NUMBER 
        AND CODE FIELDS : </font></td>
    </tr>
    <tr> 
      <td width="18" height="28">&nbsp;</td>
      <td width="38" height="28">LCCN</td>
      <td width="166" height="28">
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(7);
else {
	strTemp = request.getParameter("BOOK_LCCN");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(7); 
}
%>	  <input type="text" name="BOOK_LCCN" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="20" maxlength="32">
	  </td>
      <td width="40" height="28">ISBN</td>
      <td width="159" height="28">
<%
if(bolUseEditVal) {
	strTemp = (String)vEditInfo.elementAt(8);
	if(strTemp != null && strTemp.compareTo("0") == 0) 
		strTemp = "";
}
else {
	strTemp = request.getParameter("BOOK_ISBN");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(8); 
}
%>	  <input type="text" name="BOOK_ISBN" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="20" maxlength="32"></td>
      <td width="38" height="28">ISSN </td>
      <td width="179" height="28">
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(9);
else {
	strTemp = request.getParameter("BOOK_ISSN");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(9); 
}
%>	  <input type="text" name="BOOK_ISSN" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="20" maxlength="32"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDEE"> 
      <td height="20" colspan="5" class="thinborderALL"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FORM 
        OF MATERIAL: </font></td>
    </tr>
    <tr> 
      <td width="3%" height="22">&nbsp;</td>
      <td height="22" colspan="2" valign="bottom">Material type<font color="#FF0000">*</font> 
      </td>
      <td height="22" valign="bottom">&nbsp;</td>
      <td height="22" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28" colspan="4">
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(10);
else {
	strTemp = request.getParameter("MATERIAL_TYPE_INDEX");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(10); 
}
%>	  <select name="MATERIAL_TYPE_INDEX" 
	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10; width:300px;">
          <%=dbOP.loadCombo("MATERIAL_TYPE_INDEX","MATERIAL_TYPE"," from LMS_MAT_TYPE order by  MATERIAL_TYPE_INDEX asc",
		  	strTemp, false)%> 
        </select>
		<font size="1" ><a href='javascript:UpdateMaterialType();'><img src="../../images/update_rec.gif" border="0" align="absmiddle"></a></font>		
		</td>
    </tr>
    <tr> 
      <td height="10" colspan="5"></td>
    </tr>
    <tr bgcolor="#DDDDEE"> 
      <td height="22" colspan="5" class="thinborderALL"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PERSONAL 
        NAME :</font></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td width="11%" height="28">Author<font color="#FF0000">*</font></td>
      <td width="47%" height="28">
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(11);
else {
	strTemp = request.getParameter("AUTHOR_NAME");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(11); 
}
%>	  <input type="text" name="AUTHOR_NAME" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
      <td height="28">Dates </td>
      <td width="29%" height="28">
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(12);
else {
	strTemp = request.getParameter("AUTHOR_DATES");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(12); 
}
%>	  <input type="text" name="AUTHOR_DATES" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="20" maxlength="32"></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Title</td>
      <td height="28">
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(13);
else {
	strTemp = request.getParameter("AUTHOR_TITLE");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(13); 
}
%>	  <input type="text" name="AUTHOR_TITLE" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
      <td width="10%" height="28">Numeration</td>
      <td height="28">
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(14);
else {
	strTemp = request.getParameter("AUTHOR_NUMERATION");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(14); 
}
%>	  <input type="text" name="AUTHOR_NUMERATION" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="20" maxlength="32"></td>
    </tr>
    <tr> 
      <td height="10" colspan="5"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDEE"> 
      <td height="20" colspan="4" class="thinborderALL"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PUBLICATION 
        :</font></td>
    </tr>
    <tr> 
      <td width="3%" height="28">&nbsp;</td>
      <td width="11%" height="28">Publisher<font color="#FF0000">*</font></td>
      <td width="47%" height="28"><input type="text" name="auto_scroll" size="10" style="font-size:10px;"
	  onKeyUp="AutoScrollList('form_.auto_scroll','form_.PUBLISHER_INDEX',true);" class="textbox"
	  onBlur="document.form_.auto_scroll.value='';style.backgroundColor='white'"onFocus="style.backgroundColor='#D3EBFF'"> Auto Scroll.<br>
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(15);
else {
	strTemp = request.getParameter("PUBLISHER_INDEX");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(15); 
}
%>	  <select name="PUBLISHER_INDEX"
	  	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10px; width:400px">
          <%=dbOP.loadCombo("PUBLISHER_INDEX","PUBLISHER"," from LMS_LC_PUBLISHER order by PUBLISHER asc",
		  	strTemp, false)%> </select>
        <font size="1">
		<a href='javascript:viewList("LMS_LC_PUBLISHER","PUBLISHER_INDEX","PUBLISHER","PUBLISHER","LMS_LC_MAIN","PUBLISHER_INDEX", 
				" and LMS_LC_MAIN.IS_VALID = 1","","PUBLISHER_INDEX");'><img src="../../images/update_rec.gif" border="0" align="absmiddle"></a></font></td>
      <td width="39%" height="28">Copyright Year
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(16);
else {
	strTemp = request.getParameter("PUBLISHER_DATE");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(16); 
}
%>
	<input type="text" name="PUBLISHER_DATE" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="20" maxlength="32" onKeyUp="generateCallNo();"></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Place</td>
      <td height="28" colspan="2">
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(17);
else {
	strTemp = request.getParameter("PUBLISHER_PLACE");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(17); 
}
%>
	  <input type="text" name="PUBLISHER_PLACE" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="32"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDEE"> 
      <td height="20" colspan="3" class="thinborderALL"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PHYSICAL 
        DESCRIPTION :</font></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Material type<font color="#FF0000">*</font></td>
      <td height="28">
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(18);
else {
	strTemp = request.getParameter("MATERIAL_TYPE_PD_INDEX");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(18); 
}
%>	  <select name="MATERIAL_TYPE_PD_INDEX"
	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:14; width:300px;">
          <%=dbOP.loadCombo("MATERIAL_TYPE_PD_INDEX","MATERIAL_TYPE_PD"," from LMS_MAT_TYPE_PD order by  MATERIAL_TYPE_PD asc",
		  	strTemp, false)%> 
        </select>
		
		<a href='javascript:viewList("lms_mat_type_pd","material_type_pd_index","material_type_pd","PHYSICAL DESCRIPTION","LMS_LC_MAIN","material_type_pd_index", 
				" and LMS_LC_MAIN.IS_VALID=1","","MATERIAL_TYPE_PD_INDEX");'><img src="../../images/update_rec.gif" border="0" align="absmiddle"></a>
		</td>
    </tr>
    
	
<%if(!bolIsCIT){%>	
	<tr> 
      <td  width="3%"height="28">&nbsp;</td>
      <td width="17%" height="28">Inclusion</td>
      <td width="80%" height="28">
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(19);
else {
	strTemp = request.getParameter("PD_INCLUSION");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(19); 
}
if(strSchCode.startsWith("CGH")){%>
	  <input type="text" name="PD_INCLUSION" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="64" maxlength="64"></td>
<%}else{%>
	  <input type="text" name="PD_INCLUSION" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="32"></td>
<%}%>
    </tr>
	
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Size</td>
      <td height="28">
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(20);
else {
	strTemp = request.getParameter("PD_SIZE");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(20); 
}
%>	  <input type="text" name="PD_SIZE" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="32"></td>
    </tr>
<%}%>	

    <tr> 
      <td height="28">&nbsp;</td>
      <td valign="top">Other Physical Desc.</td>
      <td>
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(21);
else {
	strTemp = request.getParameter("PD_OTH_DESC");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(21); 
}
%>	
	<textarea name="PD_OTH_DESC" cols="60" rows="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>
      </td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDEE"> 
      <td height="20" colspan="3" class="thinborderALL"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LOCATION/CLASSIFICATION 
        DATA/CIRCULATION TYPE: </font></td>
    </tr>
    <tr> 
      <td width="3%" height="28">&nbsp;</td>
      <td height="28">Collection Location<font color="#FF0000">*</font></td>
      <td height="28"> <%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(22);
else {
	strTemp = request.getParameter("LOC_INDEX");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(22); 
}
%> <select name="LOC_INDEX"
	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10; width:300px;">
          <%=dbOP.loadCombo("LOC_INDEX","LOC_NAME"," from LMS_LIBRARY_LOC order by LOC_NAME asc",
		  	strTemp, false)%> </select> <font size="1" ><a href='javascript:viewList("LMS_LIBRARY_LOC","LOC_INDEX","LOC_NAME","LOCATION","LMS_LC_MAIN","LOC_INDEX", 
				" and LMS_LC_MAIN.IS_VALID=1","","LOC_INDEX");'><img src="../../images/update_rec.gif" border="0" align="absmiddle"></a></font></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td width="23%" height="28">Book Location Name<font color="#FF0000">*</font></td>
      <td height="28"> <%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(23);
else {
	strTemp = request.getParameter("BOOK_LOC_INDEX");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(23); 
}
%> <select name="BOOK_LOC_INDEX"
	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10; width:300px;">
          <%=dbOP.loadCombo("BOOK_LOC_INDEX","LOCATION"," from LMS_BOOK_LOC order by LOCATION asc",
		  	strTemp, false)%> </select> <font size="1" ><a href='javascript:viewList("LMS_BOOK_LOC","BOOK_LOC_INDEX","LOCATION","BOOK_LOCATION","LMS_LC_MAIN","BOOK_LOC_INDEX", 
				" and LMS_LC_MAIN.IS_VALID = 1","","BOOK_LOC_INDEX");'><img src="../../images/update_rec.gif" border="0" align="absmiddle"></a></font></td>
    </tr>
    <tr> 
      <td height="28"><input type="text" name="pageno_2" readonly="yes" size="2" style="background-color:#F2DFD2;border-width: 0px;"></td>
      <td height="28">Circulation Type<font color="#FF0000">*</font></td>
      <td height="28"> <%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(24);
else {
	strTemp = request.getParameter("CTYPE_INDEX");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(24); 
}
%> <select name="CTYPE_INDEX"
	  	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10; width:300px;">
          <%=dbOP.loadCombo("CTYPE_INDEX","DESCRIPTION"," from LMS_CLOG_CTYPE WHERE IS_VALID = 1 AND IS_DEL = 0 order by DESCRIPTION asc",
		  	strTemp, false)%> </select></td>
    </tr>
<%
String[] astrCodeRange = null;
///do not show DDC for CLDH
if(!strSchCode.startsWith("CLDH")){%>
    <tr bgcolor="#FFFFEF"> 
      <td height="20" colspan="3" class="thinborderALL"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DDC 
        INFORMATION: </font></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">General Category</td>
      <td height="28"> <%
if(bolUseEditVal) 
	strTempGenCatg = (String)vEditInfo.elementAt(25);
else {
	strTempGenCatg = request.getParameter("GEN_CATG_INDEX");
	if(strTempGenCatg == null && vEditInfo != null && vEditInfo.size() > 0)
		strTempGenCatg = (String)vEditInfo.elementAt(25); 
}
if(strTempGenCatg == null)
	strTempGenCatg = WI.getStrValue(strTempGenCatg);
%> <select name="GEN_CATG_INDEX" onChange="ReloadPageGC();">
          <option value="">Select General Category</option>
          <%=dbOP.loadCombo("GEN_CATG_INDEX","GEN_CATG"," from LMS_DDC_GEN_CATG where is_valid = 1 and is_lc=0 and is_del = 0 order by RANGE_FR asc",
		  	strTempGenCatg, false)%> </select> <%
astrCodeRange = ctlgDDC.getCodeRange(dbOP, strTempGenCatg,1);
if(astrCodeRange != null){%> <b>RANGE : <%=astrCodeRange[0]%> - <%=astrCodeRange[1]%></b> <%}%> </td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Sub-Category</td>
      <td height="28"> <%
if(bolUseEditVal) 
	strTempSubCatg = (String)vEditInfo.elementAt(26);
else {
	strTempSubCatg = request.getParameter("SUB_CATG_INDEX");
	if(strTempSubCatg == null && vEditInfo != null && vEditInfo.size() > 0)
		strTempSubCatg = (String)vEditInfo.elementAt(26); 
}
if(strTempSubCatg == null)
	strTempSubCatg = WI.getStrValue(strTempSubCatg);
%> <select name="SUB_CATG_INDEX" onChange="ReloadPageSC();">
          <option value="">Select Sub-Category</option>
          <%=dbOP.loadCombo("SUB_CATG_INDEX","SUB_CATG"," from LMS_DDC_SUB_CATG WHERE GEN_CATG_INDEX = "+
			  WI.getStrValue(strTempGenCatg,"0")+" and is_valid = 1 and is_del = 0 and is_lc=0 order by RANGE_FR asc",
		  	strTempSubCatg, false)%> </select> <%
astrCodeRange = ctlgDDC.getCodeRange(dbOP, strTempSubCatg,2);
if(astrCodeRange != null){%> <b>RANGE : <%=astrCodeRange[0]%> - <%=astrCodeRange[1]%></b> <%}%> </td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Sub-Category Entry</td>
      <td height="28"> <%
if(bolUseEditVal) 
	strTempSubCatgEntry = (String)vEditInfo.elementAt(27);
else {
	strTempSubCatgEntry = request.getParameter("SUB_CATG_ENTRY_INDEX");
	if(strTempSubCatgEntry == null && vEditInfo != null && vEditInfo.size() > 0)
		strTempSubCatgEntry = (String)vEditInfo.elementAt(27); 
}
if(strTempSubCatgEntry == null)
	strTempSubCatgEntry = WI.getStrValue(strTempSubCatgEntry);
%> <select name="SUB_CATG_ENTRY_INDEX" onChange="ReloadPageSCE();">
          <option value="">Select Sub-Category</option>
          <%=dbOP.loadCombo("SUB_CATG_ENTRY_INDEX","SUB_CATG_ENTRY"," from LMS_DDC_SUB_CATG_ENTRY WHERE SUB_CATG_INDEX = "+
			  WI.getStrValue(strTempSubCatg,"0")+" and is_valid = 1 and is_del = 0 and is_lc=0 order by SUB_CATG_CODE asc",
		  	strTempSubCatgEntry, false)%> </select> <%
if(strTempSubCatgEntry.length() > 0) {
	strTemp = dbOP.mapOneToOther("LMS_DDC_SUB_CATG_ENTRY","SUB_CATG_ENTRY_INDEX",
                strTempSubCatgEntry, "SUB_CATG_CODE",null);
	if(strTemp != null){%> <b>CODE : <%=CommonUtil.formatInt(Integer.parseInt(strTemp),3)%></b> <%}
	}%> </td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Sub-Catg Entry Class</td>
      <td height="28"> <%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(28);
else {
	strTemp = request.getParameter("SCE_CLASS_INDEX");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(28); 
}
if(strTemp == null)
	strTemp = WI.getStrValue(strTemp);
%> <select name="SCE_CLASS_INDEX">
          <%=dbOP.loadCombo("SCE_CLASS_INDEX","SCE_CLASS,SCE_CLASS_CODE"," from LMS_DDC_SCE_CLASS WHERE SUB_CATG_ENTRY_INDEX = "+
			  WI.getStrValue(strTempSubCatgEntry,"0")+" and is_valid = 1 and is_del = 0 and is_lc=0 order by SCE_CLASS_CODE asc",
		  	strTemp, false)%> </select></td>
    </tr>
<%}//DDC is not shown for CLDH%>
    <tr bgcolor="#FFFFEF"> 
      <td height="20" colspan="3" class="thinborderALL"><font color="#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LC 
        INFORMATION: </font></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">General Class</td>
      <td height="28"> <%
if(bolUseEditVal) 
	strTempGenCatg = (String)vEditInfo.elementAt(31);
else {
	strTempGenCatg = request.getParameter("lc_gc_index");
	if(strTempGenCatg == null && vEditInfo != null && vEditInfo.size() > 0)
		strTempGenCatg = (String)vEditInfo.elementAt(31); 
}//System.out.println(vEditInfo);System.out.println(strTempGenCatg);
if(strTempGenCatg == null)
	strTempGenCatg = WI.getStrValue(strTempGenCatg);
%> <select name="lc_gc_index" onChange="ReloadPageLC();">
          <option value="">Select General Class</option>
          <%=dbOP.loadCombo("GEN_CATG_INDEX","GEN_CATG +' ::: '+LC_GEN_CODE"," from LMS_DDC_GEN_CATG where is_valid = 1 and is_lc=1 order by LC_GEN_CODE asc",
		  	strTempGenCatg, false)%> </select>
      </td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Sub-Class</td>
      <td height="28"> <%
if(bolUseEditVal) 
	strTempSubCatg = (String)vEditInfo.elementAt(32);
else {
	strTempSubCatg = request.getParameter("lc_sc_index");
	if(strTempSubCatg == null && vEditInfo != null && vEditInfo.size() > 0)
		strTempSubCatg = (String)vEditInfo.elementAt(32); 
}
if(strTempSubCatg == null)
	strTempSubCatg = WI.getStrValue(strTempSubCatg);
%> <select name="lc_sc_index" onChange="ReloadPageLCSC();">
          <option value="">Select Sub-Class</option>
          <%=dbOP.loadCombo("SUB_CATG_INDEX","SUB_CATG +' ::: '+LC_SUB_CODE"," from LMS_DDC_SUB_CATG WHERE GEN_CATG_INDEX = "+
			  WI.getStrValue(strTempGenCatg,"0")+" and is_valid = 1 and is_del = 0 and is_lc=1 order by LC_SUB_CODE asc",
		  	strTempSubCatg, false)%> </select>
      </td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Sub-Class Entry</td>
      <td height="28"> <%
if(bolUseEditVal) 
	strTempSubCatgEntry = (String)vEditInfo.elementAt(33);
else {
	strTempSubCatgEntry = request.getParameter("lc_sce_index");
	if(strTempSubCatgEntry == null && vEditInfo != null && vEditInfo.size() > 0)
		strTempSubCatgEntry = (String)vEditInfo.elementAt(33); 
}
if(strTempSubCatgEntry == null)
	strTempSubCatgEntry = WI.getStrValue(strTempSubCatgEntry);
%> <select name="lc_sce_index" onChange="ReloadPageLCSCE();">
          <option value="">Select Sub-Class Enntry</option>
          <%=dbOP.loadCombo("SUB_CATG_ENTRY_INDEX","SUB_CATG_ENTRY"," from LMS_DDC_SUB_CATG_ENTRY WHERE SUB_CATG_INDEX = "+
			  WI.getStrValue(strTempSubCatg,"0")+" and is_valid = 1 and is_del = 0 and is_lc=1 order by SUB_CATG_CODE asc",
		  	strTempSubCatgEntry, false)%> </select>
        <%
 astrCodeRange = ctlgDDC.getCodeRange(dbOP, strTempSubCatgEntry,0);
if(astrCodeRange != null){%>
        <b>RANGE : <%=astrCodeRange[0]%> - <%=astrCodeRange[1]%></b> 
        <%}%>
      </td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Sub-Class Entry Class</td>
      <td height="28"> <%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(34);
else {
	strTemp = request.getParameter("lc_sce_class_index");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(34); 
}
if(strTemp == null)
	strTemp = WI.getStrValue(strTemp);
%> <select name="lc_sce_class_index">
          <%=dbOP.loadCombo("SCE_CLASS_INDEX","SCE_CLASS,SCE_CLASS_CODE"," from LMS_DDC_SCE_CLASS WHERE SUB_CATG_ENTRY_INDEX = "+
			  WI.getStrValue(strTempSubCatgEntry,"0")+" and is_valid = 1 and is_del = 0 and is_lc=1 order by SCE_CLASS_CODE asc",
		  	strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="0%" height="28">&nbsp;</td>
      <td height="28" colspan="2">Author Code<font color="#FF0000">*</font> </td>
      <td width="49%" height="28">Classification No.<font color="#FF0000">*</font></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td width="27%" height="28">
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(29);
else {
	strTemp = request.getParameter("AUTHOR_CODE");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(29); 
}
%>
<input type="text" name="AUTHOR_CODE" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="20" maxlength="32" onKeyUp="generateCallNo();"></td>
      <td width="24%" height="28" valign="bottom">
	  <a href="javascript:AuthCode();"><img src="../../images/search_recommend.gif" border="1"></a> 
        <font size="1">view possible Author Code</font></td>
      <td height="28">
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(37);
else {
	strTemp = request.getParameter("CLASSIFICATION_NO");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(37); 
}
%>	  <input type="text" name="CLASSIFICATION_NO" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="32" onKeyUp="generateCallNo();"></td>
    </tr><tr><td height="28">&nbsp;</td>
      <td height="28" align="right">Call No.<font color="#FF0000">*</font> &nbsp;&nbsp;&nbsp;</td>
      <td height="28">
<%
if(bolUseEditVal) 
	strTemp = (String)vEditInfo.elementAt(30);
else {
	strTemp = request.getParameter("CALL_NUMBER");
	if(strTemp == null && vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(30); 
}
%>	  <input type="text" name="CALL_NUMBER" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="32"></td>
      <td height="28">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <%
if(iAccessLevel > 1){%>
    <tr> 
      <td height="42" colspan="6" class="thinborderBOTTOM"><div align="center"><font size="1"></font> <font size="1"></font>
          <font size="1"><a href='javascript:PageAction(1,"");'> <img src="../../images/save_recommend.gif" border="0" name="hide_save"></a> 
          Click to save entries <a href="./add_collection_standard.jsp"><img src="../../../images/clear.gif" border="1"></a> 
          Clear entries 
          <%
if(strBookStatus != null && strBookStatus.compareTo("2") == 0) {%>
          Book is issued,delete not allowed. 
          <%}else{%>
          <a href="javascript:PageAction(0,'<%=strInfoIndex%>');"><img src="../../../images/delete.gif" border="1"></a> 
          Delete Collection information 
          <%}%>
          </font></div></td>
    </tr>
    <%}%>
    <tr> 
      <td width="28%" height="50"><div align="right"></div></td>
      <td width="12%"><a href="javascript:AddOtherInformation(1);"> <img src="../../images/added_description.gif" border="0"></a></td>
      <td width="13%"><a href="javascript:AddOtherInformation(2);"> <img src="../../images/subject_headings.gif" border="0"></a></td>
      <td width="11%"><a href="javascript:AddOtherInformation(3);"> <img src="../../images/added_author_entries.gif" border="0"></a></td>
      <td width="12%"><a href="javascript:AddOtherInformation(4);"> <img src="../../images/other_info.gif" border="0"></a> 
      </td>
      <td width="24%"><strong><font size="1">
	  <a href="javascript:AddSubjectForBook();"> Add Subject <br>for this book</a>
	  </font></strong></td>
    </tr>
  </table>
  <input type="text" name="pageno_3" readonly="yes" size="5" style="background-color:#F2DFD2;border-width: 0px;">
  
  
<input type="hidden" name="info_index" value="<%=WI.getStrValue(strInfoIndex,"")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="reload_main">
<input type="hidden" name="focus_id_page_no">
<input type="hidden" name="setup_details_index" value="<%=WI.fillTextValue("setup_details_index")%>" >
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>