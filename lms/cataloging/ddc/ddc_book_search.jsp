<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>General Category Create</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>

</head>

<script language="JavaScript">

function ReloadPageGC() {	
	document.form_.SUB_CATG_INDEX.selectedIndex =0;
	document.form_.SUB_CATG_ENTRY_INDEX.selectedIndex =0;
	document.form_.SCE_CLASS_INDEX.selectedIndex =0;
	this.ReloadPage();
}
function ReloadPageSC() {
	document.form_.SUB_CATG_ENTRY_INDEX.selectedIndex =0;
	document.form_.SCE_CLASS_INDEX.selectedIndex =0;
	this.ReloadPage();
}

function ReloadPageSCE(){
	document.form_.SCE_CLASS_INDEX.selectedIndex =0;
	this.ReloadPage();
}

function ReloadPage() {	
	document.form_.submit();
}

function ShowBookInformation(){
	document.form_.show_book_info.value = "1";	
	this.ReloadPage();
}
</script>

<%@ page language="java" import="utility.*,lms.CatalogDDC,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-DDC-Sub-Category ENTRY CLASS","ddc_book_search.jsp");
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
														"LIB_Cataloging","DDC NUMBERS",request.getRemoteAddr(),
														"ddc_book_search.jsp");
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
String[] astrSortByName    = {"Accession No","Title","Author"};
String[] astrSortByVal     = {"accession_no","book_title","author_name"};

String strGeneralCatg   	 = null;
String strSubCatg      		 = null;
String strSubCatgEntry  	 = null;
String strSubCatgEntryClass = null;


ConstructSearch conSearch = new ConstructSearch(request);
CatalogDDC ctlgDDC = new CatalogDDC();
Vector vRetResult = null;

if(WI.fillTextValue("show_book_info").length() > 0)	{
	vRetResult = ctlgDDC.getDDCOrLCBookInformation(dbOP, request);
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = ctlgDDC.getErrMsg();
	
}
%>

<body bgcolor="#DEC9CC">
<form action="./ddc_book_search.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#A8A8D5">
    <tr>
      <td height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          DDC SEARCH PAGE :::: </strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="2"><font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;General Category</td>
      <td><select name="GEN_CATG_INDEX" onChange="ReloadPageGC();">          
           <option value="">Select General Category</option>
			 <%=dbOP.loadCombo("GEN_CATG_INDEX","GEN_CATG"," from LMS_DDC_GEN_CATG where is_valid = 1 and is_del = 0 and is_lc = 0 order by RANGE_FR asc",
		  	WI.fillTextValue("GEN_CATG_INDEX"), false)%> </select>
        <%
String[] astrCodeRange = ctlgDDC.getCodeRange(dbOP, WI.fillTextValue("GEN_CATG_INDEX"),1);
if(astrCodeRange != null){
	strGeneralCatg = "RANGE : "+astrCodeRange[0] + " - " + astrCodeRange[1];
%>
        <b>RANGE : <%=astrCodeRange[0]%> - <%=astrCodeRange[1]%></b> 
        <%}%>      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;Sub-Category</td>
      <td><select name="SUB_CATG_INDEX" onChange="ReloadPageSC();">
          <option value="">Select Sub-Category</option>
          <%=dbOP.loadCombo("SUB_CATG_INDEX","SUB_CATG"," from LMS_DDC_SUB_CATG WHERE GEN_CATG_INDEX = "+
			  WI.getStrValue(WI.fillTextValue("GEN_CATG_INDEX"),"0")+" and is_valid = 1 and is_del = 0 and is_lc = 0 order by RANGE_FR asc",
		  	WI.fillTextValue("SUB_CATG_INDEX"), false)%> </select> <%
astrCodeRange = ctlgDDC.getCodeRange(dbOP, WI.fillTextValue("SUB_CATG_INDEX"),2);
if(astrCodeRange != null){
	strSubCatg = "RANGE : "+astrCodeRange[0] + " - "+ astrCodeRange[1];
%> <b>RANGE : <%=astrCodeRange[0]%> - <%=astrCodeRange[1]%></b> <%}%> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;Sub-Category Entry</td>
      <td><select name="SUB_CATG_ENTRY_INDEX" onChange="ReloadPageSCE();">
          <option value="">Select Sub-Category Entry</option>
          <%=dbOP.loadCombo("SUB_CATG_ENTRY_INDEX","SUB_CATG_ENTRY"," from LMS_DDC_SUB_CATG_ENTRY WHERE SUB_CATG_INDEX = "+
			  WI.getStrValue(WI.fillTextValue("SUB_CATG_INDEX"),"0")+" and is_valid = 1 and is_del = 0 and is_lc = 0 order by SUB_CATG_CODE asc",
		  	WI.fillTextValue("SUB_CATG_ENTRY_INDEX"), false)%> </select>
<%
if(WI.fillTextValue("SUB_CATG_ENTRY_INDEX").length() > 0) {
	strTemp = dbOP.mapOneToOther("LMS_DDC_SUB_CATG_ENTRY","SUB_CATG_ENTRY_INDEX",
                WI.fillTextValue("SUB_CATG_ENTRY_INDEX"), "SUB_CATG_CODE",null);
	if(strTemp != null){
		strSubCatgEntry = "CODE : "+CommonUtil.formatInt(Integer.parseInt(strTemp),3);
	%>
	
	<b>CODE : <%=CommonUtil.formatInt(Integer.parseInt(strTemp),3)%></b> 
    
    <%}
	}%>      </td>
    </tr>
    <tr> 
      <td width="21%" height="25">&nbsp;&nbsp;Sub-Catg Entry Class</td>
      
		<td><select name="SCE_CLASS_INDEX" onChange="ReloadPage();">
          <option value="">Select Sub Category Entry Class</option>
          <%=dbOP.loadCombo("SCE_CLASS_INDEX","SCE_CLASS"," from LMS_DDC_SCE_CLASS WHERE SUB_CATG_ENTRY_INDEX = "+
			  WI.getStrValue(WI.fillTextValue("SUB_CATG_ENTRY_INDEX"),"0")+" and is_valid = 1 and is_del = 0 and is_lc = 0 order by SCE_CLASS_CODE asc",
		  	WI.fillTextValue("SCE_CLASS_INDEX"), false)%> </select>
<%
if(WI.fillTextValue("SCE_CLASS_INDEX").length() > 0) {
	strTemp = dbOP.mapOneToOther("LMS_DDC_SCE_CLASS","SCE_CLASS_INDEX",
                WI.fillTextValue("SCE_CLASS_INDEX"), "SCE_CLASS_CODE",null);
	if(strTemp != null){
		strSubCatgEntryClass = "CODE : "+strTemp;
	%>
	
	<b>CODE : <%=strTemp%></b> 
    
    <%}
	}%>      </td>
    </tr>
	 
	 
	 
	 <tr>      
      <td height="25">&nbsp;&nbsp;Sort By </td>
      <td colspan="2"><select name="sort_by1" style="font-size:11px;">
          <option value="">N/A</option>
          <%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
        </select><select name="sort_by1_con" style="font-size:11px;">
          <option value="asc">Ascending</option>
          <%if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select>
        &nbsp;&nbsp;
        <select name="sort_by2" style="font-size:11px;">
          <option value="">N/A</option>
          <%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select><select name="sort_by2_con" style="font-size:11px;">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select>
        &nbsp;&nbsp;<select name="sort_by3" style="font-size:11px;">
          <option value="">N/A</option>
<%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select><select name="sort_by3_con" style="font-size:11px;">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
    </tr>
	 
    <tr>
       <td height="25">&nbsp;</td>
       <td><a href="javascript:ShowBookInformation();"><img src="../../../images/form_proceed.gif" border="0"></a>
		 	<font size="1">Click to show book information</font>
		 </td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<%if(strGeneralCatg != null){%>
		<tr><td height="22" align="center"><strong>GENERAL CATEGORY <%=strGeneralCatg%></strong></td></tr>
	<%}
	if(strSubCatg != null){%>
		<tr><td height="22" align="center"><strong>SUB CATEGORY <%=strSubCatg%></strong></td></tr>
	<%}
	if(strSubCatgEntry != null){%>
		<tr><td height="22" align="center"><strong>SUB CATEGORY ENTRY <%=strSubCatgEntry%></strong></td></tr>
	<%}
	if(strSubCatgEntryClass != null){%>
		<tr><td height="22" align="center"><strong>SUB CATEGORY ENTRY CLASS <%=strSubCatgEntryClass%></strong></td></tr>
	<%}
	%>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
		<td width="15%" height="20" class="thinborder" align="center" style="font-size:10px;">ACCESION/BARCODE No</td>
		<td width="13%" class="thinborder" align="center" style="font-size:10px;">CALL NUMBER</td>
		<td width="38%" class="thinborder" align="center" style="font-size:10px;">BOOOK TITLE ::: SUB-TITLE</td>
		<td width="14%" class="thinborder" align="center" style="font-size:10px;">AUTHOR</td>		
		<td width="11%" class="thinborder" align="center" style="font-size:10px;">EDITION</td>
		<td width="9%" class="thinborder" align="center" style="font-size:10px;">STATUS</td>
	</tr>
	
	<%
	for(int i = 0; i < vRetResult.size(); i+=25){
	
	if(vRetResult.elementAt(i+6) != null){
	%>
	<tr style="background-color:#9999CC;">
	   <td height="20" colspan="6" class="thinborder" style="font-size:10px;"><strong>MATERIAL TYPE : <%=vRetResult.elementAt(i+6)%></strong></td>
	</tr>
	<%}%>
	<tr>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+1));
		if(strTemp.length() > 0 && !strTemp.equals(vRetResult.elementAt(i+2)))
			strTemp += WI.getStrValue((String)vRetResult.elementAt(i+2), " / ", "" , "");
		%>
		<td height="20" class="thinborder" style="font-size:10px;"><%=strTemp%></td>
		<td class="thinborder" style="font-size:10px;"><%=WI.getStrValue(vRetResult.elementAt(i+10),"&nbsp;")%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+3)) + 
			WI.getStrValue((String)vRetResult.elementAt(i+4),":::","","");
		
		%>
		<td class="thinborder" style="font-size:10px;"><%=strTemp%></td>
		<td class="thinborder" style="font-size:10px;"><%=WI.getStrValue(vRetResult.elementAt(i+8),"&nbsp;")%></td>		
		<td class="thinborder" style="font-size:10px;"><%=WI.getStrValue(vRetResult.elementAt(i+11),"&nbsp;")%></td>
		<td class="thinborder" style="font-size:10px;"><%=WI.getStrValue(vRetResult.elementAt(i+5),"&nbsp;")%></td>
	</tr>
	<%}%>
</table>

<%}//only if vRetResult is not null%>

<input type="hidden" name="show_book_info">


</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>