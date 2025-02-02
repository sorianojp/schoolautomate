<script language="javascript">
function ieBrowser() {
	document.write("<style type=\"text/css\"> #im {");
	if(navigator.appName == "Microsoft Internet Explorer")
		document.write("FILTER: alpha(opacity=40)");
	document.write("		}	</style>");

}
</script>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%//response.setHeader("Pragma","No-Cache");
//response.setDateHeader("Expires",0);
//response.setHeader("Cache-Control","no-Cache");
%>
<style>

.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
	<script>this.ieBrowser();</script>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {

	this.SubmitOnce('form_');
}
function searchRange(){
	var searchConCSV = this.collectSearchConInCSV();
	//alert(searchConCSV);
	if(searchConCSV.length == 0) {
		alert("Must select atleast one material type.");
		return;
	}
	
	var loadPg = "./search_book_generic_rc.jsp?searchConCSV="+searchConCSV+"&publish_fr="+
					document.form_.publish_fr.value+"&publish_to="+document.form_.publish_to.value;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
/**
function ShowHide() {
	if(document.form_.show_hide.value == "0") {//shown - so hide it.
		hideLayer('myADTable1');		
		document.form_.show_hide.value = "1";
	}
	else {//hidden, so show it.. 
		showLayer('myADTable1');		
		document.form_.show_hide.value = "0";
	}
	
	
}**/
function ChangeReport(strReportType) {

	if(document.form_.report_type.value == strReportType) {
		//alert("return here.");
		return;
	}
	document.form_.report_type.value = strReportType;
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function SelectAll() {

	var vMatTypeLen = document.form_.mat_type_count.value;
	var bolCheckAll = false;
	if(document.form_.sel_all.checked)
		bolCheckAll = true;
	var obj;
	for(i = 0; i < vMatTypeLen; ++i)
		eval('document.form_.mat_type'+i+'.checked='+bolCheckAll);		

}
function collectSearchConInCSV() {
	var vMatTypeLen = document.form_.mat_type_count.value;
	var searchConCSV = "";
	for(i = 0; i < vMatTypeLen; ++i) {
		if(eval('document.form_.mat_type'+i+'.checked')) {
			if(searchConCSV.length == 0)
				searchConCSV = eval('document.form_.mat_type'+i+'.value')
			else	
				searchConCSV = searchConCSV + ","+eval('document.form_.mat_type'+i+'.value')
		}
	}
	
	return searchConCSV;
}
function PrintReport() {
	
	alert(document.form_.search_by.value);

	if(document.form_.input_fr.value.length == 0 || document.form_.input_to.value.length == 0) {
		alert("Please enter From and To Values.");
		return ;
	}
	
	var searchConCSV = this.collectSearchConInCSV();
	//alert(searchConCSV);
	if(searchConCSV.length == 0) {
		alert("Must select atleast one material type.");
		return;
	}

	document.form_.search_con_csv.value = searchConCSV;
	document.form_.print_pg.value = "1";
	this.SubmitOnce('form_');
}

///////////////////////////////////////// used to collapse and expand filter ////////////////////
var openImg = new Image();
openImg.src = "../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}


</script>
<body bgcolor="#DEC9CC" topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,lms.LmsUtil,lms.CatalogReport,java.util.Vector" %>
<%
	WebInterface WI      = new WebInterface(request);
	String strReportType = WI.fillTextValue("report_type");
	if(strReportType.length() == 0)
		strReportType = "1";
	
// if this page is calling print page, i have to forward page to print page.
	if(WI.fillTextValue("print_pg").equals("1")) {
		if(WI.fillTextValue("print_all_card").length() > 0) {%>
			<jsp:forward page="./print_all_card.jsp" />
		<%return;}
		if(strReportType.equals("1")){//biblographic report.%>
			<jsp:forward page="./bibiography_print.jsp" /> <!--report_print_cit-->
	<%		return;
		}if(strReportType.equals("2")){//biblographic report.%>
			<jsp:forward page="./shelf_card_print.jsp" />
	<%		return;
		}else{///Author card.%>
			<jsp:forward page="./author_subj_title_card_print.jsp" />
	<%		return;
	  	}  
	}

/**
	Report type 1 = Bibliography Report 
				2 = Shelf List
				3 = Author Card 
				4 = Subject Card 
				5 = Title Card 
*/

	DBOperation dbOP = null;
	String strErrMsg = null;
	int iAccessLevel = 0;
	String strTemp   = null;
	
	
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_CATALOGING"),"0"));
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-REPORTS","generic_card_report.jsp");
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
	CatalogReport CR = new CatalogReport();
	Vector vMatType = CR.getMaterialTypePD(dbOP);
/**
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
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Collection entry information successfully added.";
			if(strTemp.compareTo("2") == 0 || WI.fillTextValue("operation_").compareTo("2") == 0)
				strErrMsg = "Collection entry information successfully edited.";
			else if(strTemp.compareTo("5") == 0) 
				strErrMsg = "Collection infromation successfully duplicated.";
			else if(strTemp.compareTo("6") == 0) 
				strErrMsg = "All copies of collection information successfully edited.";
				
		}
	}

	
//get vEditInfoIf it is called.
if(WI.fillTextValue("ACCESSION_NO").length() > 0) {
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

**/
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
%>

<form name="form_" method="post" action="./generic_card_report.jsp">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING : REPORTS - BIBLIOGRAPHY REPORT::::</strong></font></div></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="24%" height="30" class="thinborderBOTTOM">
	  <font size="1"><a href="main_page.jsp" target="_self"><img src="../../images/go_back.gif" border="0" ></a>(go to main report)</font></td>
      <td width="23%" class="thinborderBOTTOM">
	  <%if(!strReportType.equals("1")){%><a href="javascript:ChangeReport(1);"><%}%><font color="#000080">Bibliography Report</font><%if(!strReportType.equals("1")){%></a><%}%></td>
      <td width="11%" class="thinborderBOTTOM">
	  <%if(!strReportType.equals("2")){%><a href="javascript:ChangeReport(2);"><%}%><font color="#000080">Shelf List</font><%if(!strReportType.equals("2")){%></a><%}%></td>
      <td width="15%" class="thinborderBOTTOM">
	  <%if(!strReportType.equals("3")){%><a href="javascript:ChangeReport(3);"><%}%><font color="#000080">Author Card</font><%if(!strReportType.equals("3")){%></a><%}%></td>
      <td width="14%" class="thinborderBOTTOM">
	  <%if(!strReportType.equals("4")){%><a href="javascript:ChangeReport(4);"><%}%><font color="#000080">Subject Card</font><%if(!strReportType.equals("4")){%></a><%}%></td>
      <td width="13%" class="thinborderBOTTOM">
	  <%if(!strReportType.equals("5")){%><a href="javascript:ChangeReport(5);"><%}%><font color="#000080">Title Card</font><%if(!strReportType.equals("5")){%></a><%}%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td height="28">&nbsp;</td>
      <td height="28" colspan="3">
	  <!--<a href="javascript:ShowHide();">-->
	  <div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')">
	  	<img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
	 	<u><strong>Change Filter Setting </strong>(by default all filters are applied)</u>		</div>
		<!--</a>--></td>
    </tr>
    <tr>
      <td height="28">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">
<span class="branch" id="branch1">
	  
	  <table width="84%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
        <tr>
          <td height="18" colspan="2" valign="bottom"><font size="1">Publishing Year : From 
              <input type="text" name="publish_fr" value="<%=WI.fillTextValue("publish_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="4" maxlength="4">
To
<input type="text" name="publish_to" value="<%=WI.fillTextValue("publish_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="4" maxlength="4"> 
(leave empty for all years) </font></td>
        </tr>
        <tr>
          <td height="18" colspan="2" valign="bottom"><font size="1">Material Type : Select ALL 
              <input name="sel_all" type="checkbox" value="1" checked onClick="SelectAll();">
          </font></td>
          </tr>
<%if(vMatType != null && vMatType.size() > 0) {
	for(int i = 0; i < vMatType.size(); i += 2) {
	%>
        <tr>
          <td width="3%" height="18" valign="bottom">
		    <font size="1">
		    <input name="mat_type<%=i/2%>" type="checkbox" value="<%=(String)vMatType.elementAt(i)%>" checked>
		    </font></td>
          <td width="79%" valign="bottom"><font size="1"><%=(String)vMatType.elementAt(i + 1)%></font></td>
        </tr>
	<%}%>
	
<input type="hidden" name="mat_type_count" value="<%=vMatType.size()/2%>">
<%}%>
      </table>
</span>	  </td>
    </tr>
    <tr> 
      <td width="33" height="28">&nbsp;</td>
      <td width="89" height="28">From</td>
      <td width="762" height="28" colspan="2"><input type="text" name="input_fr" value="<%=WI.fillTextValue("input_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="60" maxlength="128" readonly="yes">
        <a href="javascript:searchRange();">
	  <img src="../../images/search.gif" border="0" id="im" onMouseOver="high(this);" onMouseOut="low(this);"></a></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">To</td>
      <td height="28" colspan="2">
	  <input type="text" name="input_to" value="<%=WI.fillTextValue("input_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="60" maxlength="128" readonly="yes"> 
        <a href="from_to_popup_window.htm" target="_blank">
<!--<img src="../../images/search.gif" border="0" id="im" onMouseOver="high(this);" onMouseOut="low(this);">-->		</a></td>
    </tr>
<%if(strSchCode.startsWith("UI") && strReportType.equals("2")){%>
    <tr>
      <td height="28">&nbsp;</td>
      <td height="28">&nbsp;</td>
      <td height="28" colspan="2">
	  <%strTemp = WI.fillTextValue("print_all_card");
	  	if(strTemp.equals("1"))
			strTemp = " checked";
		else	
			strTemp = "";
	   %>
	  	<input name="print_all_card" type="checkbox" value="1"<%=strTemp%>>
		Shelf list, Title Card, Author Card and Subject Card.	  </td>
    </tr>
<%}%>
    <tr> 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="29" height="28">&nbsp;</td>
      <td width="95" align="right"><strong>SORT&nbsp;&nbsp;&nbsp;</strong></td>
      <td width="760">
<%
strTemp = WI.fillTextValue("sort_by");
if(strTemp.length() == 0 || strTemp.equals("AUTHOR_NAME"))
	strErrMsg = " checked";
else 
	strErrMsg = "";
%>  
	  	<input type="radio" name="sort_by" value="AUTHOR_NAME"<%=strErrMsg%>>Author &nbsp;&nbsp;
<%
if(strTemp.equals("BOOK_TITLE"))
	strErrMsg = " checked";
else 
	strErrMsg = "";
%>	  	<input type="radio" name="sort_by" value="BOOK_TITLE"<%=strErrMsg%>>Title &nbsp;&nbsp;
<%
if(strTemp.equals("CALL_NUMBER"))
	strErrMsg = " checked";
else 
	strErrMsg = "";
%>	  <input type="radio" name="sort_by" value="CALL_NUMBER"<%=strErrMsg%>>Call Number</td>
    </tr>
    <tr> 
      <td height="20" colspan="3"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="28">&nbsp;</td>
      <td width="24%">REPORT TITLE LINE 1</td>
      <td width="73%"><input type="text" name="report_l1" value="<%=WI.fillTextValue("report_l1")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" maxlength="128"></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td>REPORT TITLE LINE 2</td>
      <td><input type="text" name="report_l2" value="<%=WI.fillTextValue("report_l2")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" maxlength="128"></td>
    </tr>
    <tr>
      <td height="28">&nbsp;</td>
      <td>REPORT TITLE LINE 3</td>
      <td><input type="text" name="report_l3" value="<%=WI.fillTextValue("report_l3")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" maxlength="128"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
<%
if(strReportType.equals("1"))
	strErrMsg = "Bibliography Report";
else if(strReportType.equals("2"))
	strErrMsg = "Shelf List";
else if(strReportType.equals("3"))
	strErrMsg = "Author Card";
else if(strReportType.equals("4"))
	strErrMsg = "Subject Card";
else if(strReportType.equals("5"))
	strErrMsg = "Title Card";
%>		
      <td width="100%" height="35" valign="bottom"><div align="center">
	  <a href="javascript:PrintReport();"><img src="../../images/print.gif" border="0" ></a><font size="1">click 
          to print <%=strErrMsg%></font>
<%
if(strReportType.equals("1")){///display the print parameter for bibliography report.%>
&nbsp;&nbsp;Lines per page : <select name="lines_per_pg">
<%
strTemp = WI.fillTextValue("lines_per_pg");
int iLinesPerPg = 50;
if(strTemp.length() > 0) 
	iLinesPerPg = Integer.parseInt(strTemp);
for(int i = 40; i < 80; i += 2){
	if(i == iLinesPerPg)
		strTemp = "selected";
	else	
		strTemp = "";
	%>
	<option value="<%=i%>" <%=strTemp%>><%=i%></option>	  
<%}//end of lines per page.%>
	</select>
&nbsp;&nbsp;
	Characters per line : <select name="char_per_pg">
<%
strTemp = WI.fillTextValue("char_per_pg");
int iCharPerLine = 70;
if(strTemp.length() > 0) 
	iCharPerLine = Integer.parseInt(strTemp);
for(int i = 60; i < 120; i += 2){
	if(i == iCharPerLine)
		strTemp = "selected";
	else	
		strTemp = "";
	%>
	<option value="<%=i%>" <%=strTemp%>><%=i%></option>	  
<%}//end of chars per line.
%>		 </select> 

<%}//show for bibliography report only
else {%>
	<br><b>NOTE : It is recommended to print less than 1000 cards in one print.</b>
<%}%>
</div></td>
    </tr>
  </table>


<input type="hidden" name="report_type" value="<%=WI.fillTextValue("report_type")%>">  
<input type="hidden" name="show_hide" value="0">
<input type="hidden" name="print_pg">
<input type="hidden" name="search_by" value="<%=WI.fillTextValue("search_by")%>">
<input type="hidden" name="search_con_csv" value="<%=WI.fillTextValue("search_con_csv")%>" >
</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>