<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
 div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:0;
	top:0;
    /*give it some background and border
    background:#007fb7;*/
	background:#FFFFFF;
   
  }

</style>
</head>
<body onLoad="window.print()" topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,purchasing.Requisition,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION-Requisition Print","req_item_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	Requisition REQ = new Requisition();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strTemp = null;
	int iLoop = 2;
	int iCountRows = 0;
	double dTotalAmount = 0d;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
	String strInfo5 = SchoolInformation.getInfo5(dbOP, false, false);	
		
	int iNumRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"15"));
	boolean bolShowPresident = false;
			
	vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);	
	if(vReqInfo == null)
		strErrMsg = REQ.getErrMsg();
	else{
		if(((String)vReqInfo.elementAt(3)).equals("0")){
		  if ((WI.getStrValue((String)vReqInfo.elementAt(9),"").toLowerCase()).equals("office of the president")){
			bolShowPresident = true;
		  }
		}
	}

vReqItems = REQ.operateOnReqItems(dbOP,request,4,false, true);
if(vReqItems == null){dbOP.cleanUP();%>
	<div align="center">No canvassing information found.</div>
<%return;}if(vReqItems != null && vReqItems.size() > 0){

Vector vSupplierList = new Vector();
Vector vRetResult    = new Vector();
Vector vTotalList    = new Vector();
Vector vItemList	 = new Vector();//so that 1 item per line only
int iIndexOf = 0;
double dTemp = 0d;
for(int i =2; i < vReqItems.size(); i+=9){
	if(vSupplierList.indexOf((String)vReqItems.elementAt(i+5)) == -1)
		vSupplierList.addElement((String)vReqItems.elementAt(i+5));
		
	vRetResult.addElement(vReqItems.elementAt(i+3)+"_"+vReqItems.elementAt(i+5));
	vRetResult.addElement(vReqItems.elementAt(i+6));
	vRetResult.addElement(vReqItems.elementAt(i+7));
	
	iIndexOf = vTotalList.indexOf(vReqItems.elementAt(i+5));
	if(iIndexOf == -1){
		vTotalList.addElement(vReqItems.elementAt(i+5));
		vTotalList.addElement(vReqItems.elementAt(i+7));
	}else{
		dTemp = Double.parseDouble(WI.getStrValue(vTotalList.elementAt(iIndexOf + 1),"0"));
		dTemp = dTemp + Double.parseDouble(WI.getStrValue(vReqItems.elementAt(i+7),"0"));
		vTotalList.setElementAt(Double.toString(dTemp), iIndexOf + 1);
	}
}



	for(;iLoop < vReqItems.size();){
		iCountRows = 0;
		dTotalAmount = 0d;

if(vReqInfo != null){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr>
      <td height="25" colspan="4" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
	  <em>(formerly Visayan Maritime Academy)</em><br>
<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
<%=SchoolInformation.getAddressLine2(dbOP,false,false)%><br><br>
	MATERIALS REQUISITION & ABSTRACT OF QUOTATION
</td>
    </tr>
	<tr>
		<td width="25%">&nbsp;</td>
		<td width="50%" align="center"><!--MATERIALS REQUISITION & ABSTRACT OF QUOTATION-->&nbsp;</td>
		<td width="7%">MRAQ No.</td>
	    <td width="18%" valign="bottom"><%=WI.getStrValue(vReqInfo.elementAt(12),"&nbsp;")%></td>
	</tr>
</table>
<br><br>
<%
if(vReqItems != null){
%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">    	   
    <tr>
        <td height="20" class="thinborder">REQUESTING DEPARTMENT</td>
        <td align="center" class="thinborder">DATE<br>REQUESTED</td>
        <td align="center" class="thinborder">DATE<br>NEEDED</td>
        <td colspan="<%= 1 + (vSupplierList.size() * 2)%>" align="center" class="thinborder" valign="top">FOR PURCHASING SECTION USE ONLY</td>
    </tr>
    <tr>
		<%
		if(((String)vReqInfo.elementAt(3)).equals("0"))
			strTemp = (String)vReqInfo.elementAt(9);
		else
			strTemp = " "+ (String)vReqInfo.elementAt(8)+"/"+WI.getStrValue((String)vReqInfo.elementAt(9),"All");
		%>
        <td class="thinborder" height="20"><%=strTemp%></td>
        <td class="thinborder" align="center"><%=(String)vReqInfo.elementAt(7)%></td>
        <td class="thinborder" align="center"><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></td>
		<td class="thinborder" align="center" colspan="<%= 1 + (vSupplierList.size() * 2)%>">QUOTATIONS</td>
    </tr>
   
    <tr>
        <td height="20" colspan="3" class="thinborder">PROJECT/PURPOSE:<br><%=(String)vReqInfo.elementAt(5)%></td>
        <td class="thinborder" align="center">Suppliers<br>Terms</td>
	<%for(int i = 0; i < vSupplierList.size(); i++){%>	
        <td colspan="2" align="center" class="thinborder"><%=vSupplierList.elementAt(i)%></td>
	<%}%>        
    </tr>
    <tr> 
      <td class="thinborder" height="20" align="center">&nbsp;</td>
      <td class="thinborder" width="8%" align="center"><strong>QTY</strong></td>
      <td class="thinborder" width="8%" align="center"><strong>UNIT</strong></td>
      <td class="thinborder" width="10%" align="center">&nbsp;</td>      
  	<%for(int i = 0; i < vSupplierList.size(); i++){%>	
      <td width="7%" class="thinborder" align="center"><strong>UNIT PRICE</strong></td>
      <td width="7%" class="thinborder" align="center"><strong>AMOUNT</strong></td>
	<%}%>
    </tr>
    <% //System.out.println(iNumRows);	
		//System.out.println(vReqItems.size()/9);	
	for(;iLoop < vReqItems.size();iLoop+=9){
		iIndexOf = vItemList.indexOf((String)vReqItems.elementAt(iLoop+3));
		if(iIndexOf > -1)
			continue;
		
		if(++iCountRows > iNumRows)
			break;
		
		
		vItemList.addElement((String)vReqItems.elementAt(iLoop+3));
	%>
    <tr> 
      <td class="thinborder"  height="17"><div align="left"><%=vReqItems.elementAt(iLoop+3)%>
	  	<%=WI.getStrValue((String)vReqItems.elementAt(iLoop+4)," / ","","")%></div></td>
      <td class="thinborder"><div align="center"><%=vReqItems.elementAt(iLoop+1)%>&nbsp;</div></td>
      <td class="thinborder"><div align="center">&nbsp;<%=vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+8),"&nbsp;")%></td>      
	<%for(int i = 0; i < vSupplierList.size(); i++){
		iIndexOf = vRetResult.indexOf((String)vReqItems.elementAt(iLoop+3)+"_"+(String)vSupplierList.elementAt(i));
		strTemp = "&nbsp;";
		strErrMsg = "&nbsp;";
		if(iIndexOf > -1){
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(iIndexOf + 1), true);
			strErrMsg = CommonUtil.formatFloat((String)vRetResult.elementAt(iIndexOf + 2), true);
		}
	%>
      <td class="thinborder" align="right"><%=strTemp%>&nbsp;</td>
      <td class="thinborder" align="right"><%=strErrMsg%>&nbsp;</td>
	<%}%>
    </tr>
    <%}//end of inner for loop
	
	if(iLoop + 9 >= vReqItems.size()){%>
	<tr>
		<td class="thinborder" colspan="4" align="right"><strong>TOTAL</strong></td>
	<%for(int i = 0; i < vSupplierList.size(); i++){
		iIndexOf = vTotalList.indexOf(vSupplierList.elementAt(i));
		strTemp = "0.00";
		if(iIndexOf > -1)
			strTemp = CommonUtil.formatFloat((String)vTotalList.elementAt(iIndexOf + 1), true);
	%>
		<td class="thinborder">&nbsp;</td>
		
		<td class="thinborderBOTTOM" align="right"><strong><%=strTemp%></strong>&nbsp;</td>
		<%}%>
	</tr>
	
	<%}
	%>
  </table>



<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="30" colspan="6">&nbsp;</td></tr>
	<tr>
		<td>Requested by:</td>
		<td>Noted by:</td>
		<td>Canvassed by:</td>
		<td>Verified by:</td>
		<td>Recommending Approval</td>
		<td>Approved by:</td>
	</tr>
	<tr>
		<td height="30" valign="bottom" width="16%"><div style="border-bottom:solid 1px #000000; width:95%;"><%=WI.getStrValue(vReqInfo.elementAt(2))%></div></td>
		<td valign="bottom" width="16%"><div style="border-bottom:solid 1px #000000; width:95%;"><%=WI.getStrValue(vReqInfo.elementAt(25))%></div></td>
		<td valign="bottom" width="17%"><div style="border-bottom:solid 1px #000000; width:95%;"><%=WI.getStrValue(vReqInfo.elementAt(24))%></div></td>
		<td valign="bottom" width="17%"><div style="border-bottom:solid 1px #000000; width:95%;"><%=WI.getStrValue(vReqInfo.elementAt(27))%></div></td>
		<td valign="bottom" width="17%"><div style="border-bottom:solid 1px #000000; width:95%;"><%=WI.getStrValue(vReqInfo.elementAt(28))%></div></td>
		<td valign="bottom" width="17%"><div style="border-bottom:solid 1px #000000; width:95%;"><%=WI.getStrValue(vReqInfo.elementAt(26))%></div></td>
	</tr>
</table>
  
	<%if (iLoop < vReqItems.size()) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
	
    } // if(vReqItems != null)%
	
	} // if(vReqInfo != null)  	
	}// outermost for loop
}%>
<div id="processing" class="processing">
<table cellpadding="0" cellspacing="0" border="0" Width="100%" style="border:solid 1px #000000;">
	<tr>
		<td>Form ID.</td>
		<td>: Property 0003</td>
	</tr>
	<tr>
		<td>Rev. Number</td>
		<td>: 02</td>
	</tr>
	<tr>
		<td>Rev. Date</td>
		<td>: 09.01.06</td>
	</tr>
</table>
</div>	

</body>
</html>
<%
	dbOP.cleanUP();
%>